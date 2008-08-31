module Ruboss
  module Generator
    class GeneratedAttribute
      attr_accessor :name, :type, :flex_name

      def initialize(name, type)
        @name, @type = name, type.to_sym
        @flex_name = name.camelcase(:lower)      
      end

      def field_type
        @field_type ||= case type
          when :integer, :float, :decimal   then :text_field
          when :datetime, :timestamp, :time then :datetime_select
          when :date                        then :date_select
          when :string                      then :text_field
          when :text                        then :text_area
          when :boolean                     then :check_box
          else
            :text_field
        end      
      end

      def default(prefix = '')
        @default = case type
          when :integer                     then 1
          when :float                       then 1.5
          when :decimal                     then "9.99"
          when :datetime, :timestamp, :time then Time.now.to_s(:db)
          when :date                        then Date.today.to_s(:db)
          when :string                      then prefix + name.camelize + "String"
          when :text                        then prefix + name.camelize + "Text"
          when :boolean                     then false
          else
            ""
        end      
      end
      
      def flex_type
        @flex_type = case type
          when :integer                     then 'int'
          when :date, :datetime, :time      then 'Date'
          when :boolean                     then 'Boolean'
          when :float, :decimal             then 'Number'
          else
            'String'
        end
      end
      
      def flex_default(prefix = '')
        @flex_default = case type
          when :integer, :float, :decimal   then '0'
          when :string, :text               then '""'
          when :boolean                     then 'false'
          else
            'null'
        end
      end
    end
  end
end