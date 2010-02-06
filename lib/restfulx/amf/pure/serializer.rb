require 'amf/pure/io_helpers'

module RestfulX::AMF
  module Pure
    # AMF3 implementation of serializer
    class AMF3Serializer
      attr_accessor :stream, :object_cache, :string_cache

      def initialize()
        @stream = ""
        @string_cache = SerializerCache.new
        @object_cache = SerializerCache.new
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
        record_id = record.respond_to?(:unique_id) ? record.unique_id : record.object_id
        
        partials = {}
        
        if @object_cache[record_id] != nil
          write_reference(@object_cache[record_id])
        else
          # Cache object
          @object_cache.cache(record_id)

          # Always serialize things as dynamic objects
          @stream << AMF3_DYNAMIC_OBJECT

          # Write class name/anonymous
          class_name = RestfulX::AMF::ClassMapper.get_as_class_name(record)
          if class_name
            write_utf8_vr(class_name)
          else
            @stream << AMF3_ANONYMOUS_OBJECT
          end
                    
          serializable_names.each do |name|
            write_utf8_vr(name.to_s.camelize(:lower))
            result = record.send(name)
            if result.respond_to?(:to_amf)
              result_id = result.respond_to?(:unique_id) ? result.unique_id : result.object_id
              if @object_cache[result_id] != nil
                @stream << AMF3_OBJECT_MARKER
                write_reference(@object_cache[result_id])
              else
                partials[name.to_s] = result.class.class_name
                serialize_record(result, ['id'])
              end
            else
              serialize_property(result)
            end
          end
          
          write_utf8_vr("partials")
          serialize_property(partials)
          
          block.call(self) if block_given?

          # Write close
          @stream << AMF3_CLOSE_DYNAMIC_OBJECT
        end
        self
      end
      
      def serialize_records(records, options = {}, &block)
        @stream << AMF3_ARRAY_MARKER

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
                
        self
      end

      def write_reference(index)
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
        
        @object_cache.cache_index += 1

        # Build AMF string
        time.utc unless time.utc?
        seconds = (time.to_f * 1000).to_i
        @stream << pack_integer(AMF3_NULL_MARKER)
        @stream << pack_double(seconds)
      end

      def write_date(date)
        @stream << AMF3_DATE_MARKER
        
        @object_cache.cache_index += 1

        # Build AMF string
        seconds = ((date.strftime("%s").to_i) * 1000).to_i
        @stream << pack_integer(AMF3_NULL_MARKER)
        @stream << pack_double(seconds)
      end
      
      def write_hash(hash, &block)
        @stream << AMF3_OBJECT_MARKER
        if @object_cache[hash] != nil
          write_reference(@object_cache[hash])
        else
          # Cache object
          @object_cache.cache(hash)

          # Always serialize things as dynamic objects
          @stream << AMF3_DYNAMIC_OBJECT << AMF3_ANONYMOUS_OBJECT
          
          hash.keys.sort.each do |name|
            write_utf8_vr(name.to_s.camelize(:lower))
            serialize_property(hash[name])
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
          @string_cache.cache(str)

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

    class SerializerCache < Hash
      attr_accessor :cache_index
    
      def initialize
        @cache_index = 0
      end

      def cache(obj)
        self[obj] = @cache_index
        @cache_index += 1
      end
    end
  end
end