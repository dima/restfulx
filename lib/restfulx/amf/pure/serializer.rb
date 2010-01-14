require 'amf/pure/io_helpers'

module RestfulX::AMF
  module Pure
    # AMF3 implementation of serializer
    class AMF3Serializer
      attr_accessor :stream, :object_cache, :string_cache

      def initialize(params = {})
        @stream = ""
        @string_cache = SerializerCache.new :string
        @object_cache = SerializerCache.new :object
        @serializable_names = params[:serializable_names]
        @opts = params[:options]
      end

      def version
        3
      end
      
      def to_s
        @stream
      end

      def serialize(obj, &block)
        if obj.is_a?(NilClass)
          write_null
        elsif obj.is_a?(TrueClass)
          write_true
        elsif obj.is_a?(FalseClass)
          write_false
        elsif obj.is_a?(Float)
          write_float(obj)
        elsif obj.is_a?(Integer)
          write_integer(obj)
        elsif obj.is_a?(Symbol) || obj.is_a?(String)
          write_string(obj.to_s)
        elsif obj.is_a?(Time) || obj.is_a?(DateTime)
          write_time(obj)
        elsif obj.is_a?(Date)
          write_date(obj)
        elsif obj.is_a?(Array)
          write_array(obj, &block)
        elsif obj.is_a?(Object)
          write_object(obj, &block)
        end
        @stream
      end

      def write_reference index
        header = index << 1 # shift value left to leave a low bit of 0
        @stream << pack_integer(header)
      end

      def write_null
        @stream << AMF3_NULL_MARKER
      end

      def write_true
        @stream << AMF3_TRUE_MARKER
      end

      def write_false
        @stream << AMF3_FALSE_MARKER
      end

      def write_integer(int)
        if int < MIN_INTEGER || int > MAX_INTEGER # Check valid range for 29 bits
          write_float(int.to_f)
        else
          @stream << AMF3_INTEGER_MARKER
          @stream << pack_integer(int)
        end
      end

      def write_float(float)
        @stream << AMF3_DOUBLE_MARKER
        @stream << pack_double(float)
      end

      def write_string(str)
        @stream << AMF3_STRING_MARKER
        write_utf8_vr(str)
      end

      def write_time(time)
        @stream << AMF3_DATE_MARKER
        if @object_cache[time] != nil
          write_reference(@object_cache[time])
        else
          @object_cache.add_obj(time)

          # Build AMF string
          time.utc unless time.utc?
          seconds = (time.to_f * 1000).to_i
          @stream << pack_integer(AMF3_NULL_MARKER)
          @stream << pack_double(seconds)
        end
      end

      def write_date(date)
        @stream << AMF3_DATE_MARKER
        if @object_cache[date] != nil
          write_reference(@object_cache[date])
        else
          @object_cache.add_obj(date)

          # Build AMF string
          seconds = ((date.strftime("%s").to_i) * 1000).to_i
          @stream << pack_integer(AMF3_NULL_MARKER)
          @stream << pack_double(seconds)
        end
      end

      def write_array(array)
        @stream << AMF3_ARRAY_MARKER
        if @object_cache[array] != nil
          write_reference(@object_cache[array])
        else
          # Cache array
          @object_cache.add_obj(array)

          header = array.length << 1 # make room for a low bit of 1
          header = header | 1 # set the low bit to 1
          @stream << pack_integer(header)
          @stream << AMF3_CLOSE_DYNAMIC_ARRAY
          array.each do |elem|
            if elem.respond_to?(:to_amf)
              puts elem.inspect
              @stream << elem.to_amf(@opts)
            else
              serialize(elem)
            end
          end
          
          block.call(self) if block_given?
        end
      end

      def write_object(obj, &block)
        @stream << AMF3_OBJECT_MARKER
        if @object_cache[obj] != nil
          write_reference(@object_cache[obj])
        else
          # Cache object
          @object_cache.add_obj(obj)

          # Always serialize things as dynamic objects
          @stream << AMF3_DYNAMIC_OBJECT

          # Write class name/anonymous
          class_name = RestfulX::AMF::ClassMapper.get_as_class_name(obj)
          if class_name
            write_utf8_vr(class_name)
          else
            @stream << AMF3_ANONYMOUS_OBJECT
          end
          
          hash_like = obj.respond_to?("[]=")
          @serializable_names.sort.each do |name|
            write_utf8_vr(name.to_s.camelize(:lower))
            if hash_like
              serialize(obj[name.to_sym])
            else
              serialize(obj.send(name))
            end
          end

          block.call(self) if block_given?

          # Write close
          @stream << AMF3_CLOSE_DYNAMIC_OBJECT
        end
      end

      def write_utf8_vr(str)
        if str == ''
          @stream << AMF3_EMPTY_STRING
        elsif @string_cache[str] != nil
          write_reference(@string_cache[str])
        else
          # Cache string
          @string_cache.add_obj(str)

          # Build AMF string
          header = str.length << 1 # make room for a low bit of 1
          header = header | 1 # set the low bit to 1
          @stream << pack_integer(header)
          @stream << str
        end
      end

      private
      include RestfulX::AMF::Pure::WriteIOHelpers
    end

    class SerializerCache #:nodoc:all:
      def self.new(type)
        if type == :string
          StringCache.new
        elsif type == :object
          ObjectCache.new
        end
      end

      class StringCache < Hash
        def initialize
          @cache_index = 0
        end

        def add_obj(str)
          self[str] = @cache_index
          @cache_index += 1
        end
      end

      class ObjectCache < Hash
        def initialize
          @cache_index = 0
        end

        def [](obj)
          super(obj.object_id)
        end

        def add_obj(obj)
          self[obj.object_id] = @cache_index
          @cache_index += 1
        end
      end
    end
  end
end