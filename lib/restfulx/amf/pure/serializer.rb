require 'amf/pure/io_helpers'

module RestfulX::AMF
  module Pure
    # AMF3 Type Markers
    AMF3_UNDEFINED_MARKER    =  0x00 #"\000"
    AMF3_NULL_MARKER         =  0x01 #"\001"
    AMF3_FALSE_MARKER        =  0x02 #"\002"
    AMF3_TRUE_MARKER         =  0x03 #"\003"
    AMF3_INTEGER_MARKER      =  0x04 #"\004"
    AMF3_DOUBLE_MARKER       =  0x05 #"\005"
    AMF3_STRING_MARKER       =  0x06 #"\006"
    AMF3_XML_DOC_MARKER      =  0x07 #"\a"
    AMF3_DATE_MARKER         =  0x08 #"\b"
    AMF3_ARRAY_MARKER        =  0x09 #"\t"
    AMF3_OBJECT_MARKER       =  0x0A #"\n"
    AMF3_XML_MARKER          =  0x0B #"\v"
    AMF3_BYTE_ARRAY_MARKER   =  0x0C #"\f"

    # Other AMF3 Markers
    AMF3_EMPTY_STRING             = 0x01
    AMF3_ANONYMOUS_OBJECT         = 0x01
    AMF3_DYNAMIC_OBJECT           = 0x0B
    AMF3_CLOSE_DYNAMIC_OBJECT     = 0x01
    AMF3_CLOSE_DYNAMIC_ARRAY      = 0x01

    # Other Constants
    MAX_INTEGER               = 268435455
    MIN_INTEGER               = -268435456
    
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
    
    class RxAMFSerializer
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
      
      def write_vr(name)
        if name == ''
          @stream << AMF3_EMPTY_STRING
        elsif @string_cache[name] != nil
          write_reference(@string_cache[name])
        else
          # Cache string
          @string_cache.cache(name)

          # Build AMF string
          header = name.length << 1 # make room for a low bit of 1
          header = header | 1 # set the low bit to 1
          @stream << pack_integer(header)
          @stream << name
        end
        
        nil
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
      
      def serialize_models_array(records, options = {})
        @stream << AMF3_OBJECT_MARKER << AMF3_XML_DOC_MARKER
        write_vr('org.restfulx.messaging.io.ModelsCollection')
        @object_cache.cache_index += 2

        serialize_records(records, options)      
      end

      def serialize_typed_array(records, options = {})
        @stream << AMF3_OBJECT_MARKER << AMF3_XML_DOC_MARKER
        write_vr('org.restfulx.messaging.io.TypedArray')
        @object_cache.cache_index += 1
        serialize_property(options[:attributes])
        @object_cache.cache_index += 1

        serialize_records(records, options)      
      end

      def serialize_errors(errors)
        @stream << AMF3_OBJECT_MARKER << AMF3_XML_DOC_MARKER
        write_vr('org.restfulx.messaging.io.ServiceErrors')
        serialize_property(errors)
        @stream << AMF3_CLOSE_DYNAMIC_OBJECT
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
            write_vr(class_name)
          else
            @stream << AMF3_ANONYMOUS_OBJECT
          end

          serializable_names.each do |prop|
            if prop.is_a?(Hash)
              record_name = prop[:name]
              record_value = record[record_name]
              ref_name = prop[:ref_name]
              ref_class = prop[:ref_class]
              ref_class_name = ref_class.class_name
              result_id = "#{ref_class_name}_#{record_value}" if record_value

              write_vr(ref_name)
              if result_id               
                if @object_cache[result_id]
                  @stream << AMF3_OBJECT_MARKER
                  write_reference(@object_cache[result_id])
                else
                  partials[ref_name.to_s] = ref_class_name
                  unless partial = options[:cached_instances][ref_class_name]
                    options[:cached_instances][ref_class_name] = ref_class.new
                    partial = options[:cached_instances][ref_class_name]
                  end
                  partial.id = record_value
                  serialize_record(partial, ['id'])
                end
              else
                write_null
              end
            else
              write_vr(prop.to_s.camelize(:lower))
              serialize_property(record[prop])
            end
          end

          write_vr("partials")
          serialize_property(partials)

          block.call(self) if block_given?

          # Write close
          @stream << AMF3_CLOSE_DYNAMIC_OBJECT
        end
        self
      end

      private
      def serialize_records(records, options = {})
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
        write_vr(str)
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
      
      def write_hash(hash)
        @stream << AMF3_OBJECT_MARKER
        if @object_cache[hash] != nil
          write_reference(@object_cache[hash])
        else
          # Cache object
          @object_cache.cache(hash)

          # Always serialize things as dynamic objects
          @stream << AMF3_DYNAMIC_OBJECT << AMF3_ANONYMOUS_OBJECT
                    
          hash.each do |key, value|
            write_vr(key.to_s.camelize(:lower))
            serialize_property(value)
          end

          # Write close
          @stream << AMF3_CLOSE_DYNAMIC_OBJECT
        end
      end
      
      include RestfulX::AMF::Pure::WriteIOHelpers
    end
  end
end