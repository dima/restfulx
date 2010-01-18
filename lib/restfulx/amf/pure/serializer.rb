require 'amf/pure/io_helpers'

module RestfulX::AMF
  module Pure
    # AMF3 implementation of serializer
    class AMF3Serializer
      attr_accessor :stream, :object_cache, :string_cache

      def initialize()
        @stream = ""
        @string_cache = SerializerCache.new :string
        @object_cache = SerializerCache.new :object
      end

      def version
        3
      end
      
      def to_s
        @stream
      end

      def serialize_property(prop)
        if prop.is_a?(NilClass)
          write_null
        elsif prop.is_a?(TrueClass)
          write_true
        elsif prop.is_a?(FalseClass)
          write_false
        elsif prop.is_a?(Float)
          write_float(prop)
        elsif prop.is_a?(Integer)
          write_integer(prop)
        elsif prop.is_a?(Symbol) || prop.is_a?(String)
          write_string(prop.to_s)
        elsif prop.is_a?(Time) || prop.is_a?(DateTime)
          write_time(prop)
        elsif prop.is_a?(Date)
          write_date(prop)
        elsif prop.is_a?(Hash)
          write_hash(prop)
        end
        self
      end
      
      def serialize_record(record, serializable_names = nil, options = {}, &block)
        @stream << AMF3_OBJECT_MARKER
        if @object_cache[record] != nil
          write_reference(@object_cache[record])
        else
          # Cache object
          @object_cache.add_obj(record)

          # Always serialize things as dynamic objects
          @stream << AMF3_DYNAMIC_OBJECT

          # Write class name/anonymous
          class_name = RestfulX::AMF::ClassMapper.get_as_class_name(record)
          if class_name
            write_utf8_vr(class_name)
          else
            @stream << AMF3_ANONYMOUS_OBJECT
          end
          
          associations = Hash[*record.class.reflect_on_all_associations(:belongs_to).collect { |assoc| [assoc.primary_key_name, assoc.name] }.flatten]
          
          serializable_names.each do |name|
            if associations.has_key?(name)
              name = associations[name]
            end
            write_utf8_vr(name.to_s.camelize(:lower))
            result = record.send(name)
            if result.respond_to?(:to_amf)
              if @object_cache[result] != nil
                result.to_amf(options)
              else
                write_null
              end
            else
              serialize_property(result)
            end
          end

          block.call(self) if block_given?

          # Write close
          @stream << AMF3_CLOSE_DYNAMIC_OBJECT
        end
        self
      end
      
      def serialize_records(records, options = {}, &block)
        @stream << AMF3_ARRAY_MARKER
        if @object_cache[records] != nil
          write_reference(@object_cache[records])
        else
          # Cache array
          @object_cache.add_obj(records)

          header = records.length << 1 # make room for a low bit of 1
          header = header | 1 # set the low bit to 1
          @stream << pack_integer(header)
          @stream << AMF3_CLOSE_DYNAMIC_ARRAY
          records.each do |elem|
            if elem.respond_to?(:to_amf)
              elem.to_amf(options)
            else
              serialize_property(elem)
            end
          end

          block.call(self) if block_given?
        end
        self
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
      
      def write_hash(obj, &block)
        @stream << AMF3_OBJECT_MARKER
        if @object_cache[obj] != nil
          write_reference(@object_cache[obj])
        else
          # Cache object
          @object_cache.add_obj(obj)

          # Always serialize things as dynamic objects
          @stream << AMF3_DYNAMIC_OBJECT << AMF3_ANONYMOUS_OBJECT
          
          obj.keys.sort.each do |name|
            write_utf8_vr(name.to_s.camelize(:lower))
            serialize_property(obj[name.to_sym])
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
          obj_id = obj.respond_to?(:attributes) ? "#{obj.class.to_s}_#{obj.attributes()['id']}" : obj.object_id
          super(obj_id)
        end

        def add_obj(obj)
          obj_id = obj.respond_to?(:attributes) ? "#{obj.class.to_s}_#{obj.attributes()['id']}" : obj.object_id  
          self[obj_id] = @cache_index
          @cache_index += 1
        end
      end
    end
  end
end