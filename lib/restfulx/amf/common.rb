require 'amf/constants'

module RestfulX::AMF
  class RxAMFSerializer < AMF3Serializer
    def serialize_models_array(records, options = {}, &block)
      @stream << AMF3_OBJECT_MARKER << AMF3_XML_DOC_MARKER
      write_utf8_vr('org.restfulx.messaging.io.ModelsCollection')
      @object_cache.cache_index += 2
         
      block_given? ? serialize_records(records, options, &block) : serialize_records(records, options)      
    end

    def serialize_typed_array(records, options = {}, &block)
      @stream << AMF3_OBJECT_MARKER << AMF3_XML_DOC_MARKER
      write_utf8_vr('org.restfulx.messaging.io.TypedArray')
      @object_cache.cache_index += 1
      serialize_property(options[:attributes])
      @object_cache.cache_index += 1
            
      block_given? ? serialize_records(records, options, &block) : serialize_records(records, options)      
    end

    def serialize_errors(errors)
      @stream << AMF3_OBJECT_MARKER << AMF3_XML_DOC_MARKER
      write_utf8_vr('org.restfulx.messaging.io.ServiceErrors')
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
          write_utf8_vr(class_name)
        else
          @stream << AMF3_ANONYMOUS_OBJECT
        end

        serializable_names.each do |prop|
          if prop.is_a?(Hash)
            record_name = prop[:assoc][:name]
            name = prop[:assoc][:reflected][:name].to_s.camelize(:lower)
            record_klass = prop[:assoc][:reflected][:klass].class_name
            result_id = "#{record_klass}_#{record[record_name]}" if record[record_name]

            write_utf8_vr(name)
            if result_id               
              if @object_cache[result_id]
                @stream << AMF3_OBJECT_MARKER
                write_reference(@object_cache[result_id])
              else
                partials[name.to_s] = record_klass
                partial = prop[:assoc][:reflected][:klass].new
                partial.id = record[record_name]
                serialize_record(partial, ['id'])
              end
            else
              write_null
            end
          else
            write_utf8_vr(prop.to_s.camelize(:lower))
            serialize_property(record[prop])
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
  end
end