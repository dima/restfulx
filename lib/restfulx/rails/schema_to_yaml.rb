# Used for analyzing your schema and exporting a model.yml file for Rx
# Provides facilities to convert an existing Rails application schema.rb file to 
# RestfulX model.yml file
module SchemaToYaml
  # SchemaToYaml.schema_to_yaml
  #  - set of commands that introspects your database and formats your model.yml for export
  def self.schema_to_yaml
    # Iterates through your database, and sets up table_arr with all columns
    #  - excludes schema_info/schema_migrations/and any other tables you specify in restfulx.yml
    table_arr = ActiveRecord::Base.connection.tables - 
      %w(schema_info schema_migrations).map - 
      RxSettings.ignored.tables[0].split
      
    # Excludes columns from each table
    disregarded_columns = %w(id created_at updated_at) + RxSettings.ignored.fields[0].split
    
    # Schema variable is appended to throughout, and is the variable exported to model.yml
    schema = []
    
    # Set up empty array for has_many relationships
    @array_of_has_manies = []

    # Iterates through each table, and checks for any database field ending in _id
    table_arr.each do |table|
      column_arr = ActiveRecord::Base.connection.columns(table)
      column_arr.each do |col|
        col_name = col.name.to_s
        @array_of_has_manies << "#{col_name.gsub(/_id\b/,'')}_#{table}" if col_name[-3,3]=='_id'
      end
    end

    table_arr.each do |table|
      # Set up empty arrays for other associations
      belong_tos = []
      has_manies = []
      polymorphics = []

      # Append table name to schema
      #  - project:
      schema << "#{table.singularize}:\n" 
      column_arr = ActiveRecord::Base.connection.columns(table)

      column_arr.each do |col|
        col_name = col.name.to_s
        
        # Ignore certain columns
        columns_check = []
        disregarded_columns.each {|dc| columns_check << col_name.include?(dc) }
        
        # Sets up polymorphics array, we'll need to check for duplicates below
        polymorphics << col_name.gsub('_id','PMCHECK').gsub('_type','PMCHECK')

        # Appends each column under respective table
        schema << " - #{col_name}: #{col.type}\n" unless columns_check.include?(true)

        # Checks for certain column names
        #  - If it finds parent_id it sets up a tree_model for generation
        #  - If it finds _file_size it sets up attachment for generation
        #  - Sets up belong_tos
        if col_name == 'parent_id'
          schema << " - tree_model: [#{col_name.gsub(/_id\b/,'')}]\n" 
        elsif col_name =~ /_file_size$/
          schema << " - attachment_field: [#{col_name.gsub(/_file_size$/,'')}]\n" 
        else
          belong_tos << col_name.gsub(/_id\b/,', ') if col_name[-3,3]=='_id' && !disregarded_columns.include?(col_name)
        end
      end

      # Checks for duplicates in the polymorphics array (used for error checking)
      if polymorphics.dups.size > 0
        schema << " - polymorphic: [#{polymorphics.dups.first.gsub('PMCHECK','')}]\n" 
        @polymorphic = polymorphics.dups.first.gsub('PMCHECK','')
      end

      # Cleans up has many
      @array_of_has_manies.each do |hm|
        sanity_check = hm.gsub(/^#{table.singularize}_/,'')
        if hm =~ /^#{table.singularize}_/ && table_arr.include?(sanity_check)
          has_manies << hm.gsub(/^#{table.singularize}_/,'') + ', '
        end
      end

      # Appends belong_to's to schema
      if belong_tos.size > 0
        belong_tos = belong_tos.delete_if {|x| x == "#{@polymorphic}, " }
        last_in_array_fix = belong_tos.last
        last_in_array_fix = last_in_array_fix.gsub(', ','')
        belong_tos.pop
        belong_tos << last_in_array_fix
        schema << " - belongs_to: [#{belong_tos}]\n" 
      end

      # Appends has_manies' to schema
      if has_manies.size > 0
        last_in_array_fix = has_manies.last
        last_in_array_fix = last_in_array_fix.gsub(', ','')
        has_manies.pop
        has_manies << last_in_array_fix
        schema << " - has_many: [#{has_manies}]\n" 
      end

      schema << "\n" 
    end

    # Writes model.yml file
    yml_file = File.join(RAILS_ROOT, "db", "model.yml")
    File.open(yml_file, "w") { |f| f << schema.to_s }
    puts "Model.yml created at db/model.yml" 
  end
end
