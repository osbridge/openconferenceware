require 'rubygems'
require 'yaml'
require 'active_record'


module YamlDb
	def self.dump(filename)
		disable_logger
		YamlDb::Dump.dump(File.new(filename, "w"))
		reenable_logger
	end

	def self.load(filename)
		disable_logger
		YamlDb::Load.load(File.new(filename, "r"))
		reenable_logger
	end

	def self.disable_logger
		@@old_logger = ActiveRecord::Base.logger
		ActiveRecord::Base.logger = nil
	end

	def self.reenable_logger
		ActiveRecord::Base.logger = @@old_logger
	end
end


module YamlDb::Utils
	def self.chunk_records(records)
		yaml = [ records ].to_yaml
		yaml.sub!("--- \n", "")
		yaml.sub!('- - -', '  - -')
		yaml
	end

	def self.unhash(hash, keys)
		keys.map { |key| hash[key] }
	end

	def self.unhash_records(records, keys)
		records.each_with_index do |record, index|
			records[index] = unhash(record, keys)
		end

		records
	end

	def self.convert_booleans(records, columns)
		records.each do |record|
			columns.each do |column|
				next if is_boolean(record[column])
				record[column] = (record[column] == 't' or record[column] == '1')
			end
		end
		records
	end

	def self.boolean_columns(table)
		columns = ActiveRecord::Base.connection.columns(table).reject { |c| c.type != :boolean }
		columns.map { |c| c.name }
	end

	def self.is_boolean(value)
		value.kind_of?(TrueClass) or value.kind_of?(FalseClass)
	end

	def self.quote_table(table)
		ActiveRecord::Base.connection.quote_table_name(table)
	end
end


module YamlDb::Dump
	def self.dump(io)
		tables.each do |table|
			dump_table(io, table)
		end
	end

	def self.tables
		ActiveRecord::Base.connection.tables.reject { |table| ['schema_info', 'schema_migrations'].include?(table) }
	end

	def self.dump_table(io, table)
		return if table_record_count(table).zero?

		dump_table_columns(io, table)
		dump_table_records(io, table)
	end

	def self.dump_table_columns(io, table)
		io.write("\n")
		io.write({ table => { 'columns' => table_column_names(table) } }.to_yaml)
	end

	def self.dump_table_records(io, table)
		table_record_header(io)

		column_names = table_column_names(table)

		each_table_page(table) do |records|
			rows = YamlDb::Utils.unhash_records(records, column_names)
			io.write(YamlDb::Utils.chunk_records(records))
		end
	end

	def self.table_record_header(io)
		io.write("  records: \n")
	end

	def self.table_column_names(table)
		ActiveRecord::Base.connection.columns(table).map { |c| c.name }
	end

	def self.each_table_page(table, records_per_page=1000)
		total_count = table_record_count(table)
		pages = (total_count.to_f / records_per_page).ceil - 1
		id = table_column_names(table).first
		boolean_columns = YamlDb::Utils.boolean_columns(table)
		quoted_table_name = YamlDb::Utils.quote_table(table)

		(0..pages).to_a.each do |page|
			sql = ActiveRecord::Base.connection.add_limit_offset!("SELECT * FROM #{quoted_table_name} ORDER BY #{id}",
				:limit => records_per_page, :offset => records_per_page * page
			)
			records = ActiveRecord::Base.connection.select_all(sql)
			records = YamlDb::Utils.convert_booleans(records, boolean_columns)
			yield records
		end
	end

	def self.table_record_count(table)
		ActiveRecord::Base.connection.select_one("SELECT COUNT(*) FROM #{YamlDb::Utils.quote_table(table)}").values.first.to_i
	end
end


module YamlDb::Load
	def self.load(io)
		ActiveRecord::Base.connection.transaction do
			YAML.load_documents(io) do |ydoc|
				ydoc.keys.each do |table_name|
					next if ydoc[table_name].nil?
					load_table(table_name, ydoc[table_name])
				end
			end
		end
	end

	def self.truncate_table(table)
		begin
			ActiveRecord::Base.connection.execute("TRUNCATE #{YamlDb::Utils.quote_table(table)}")
		rescue Exception
			ActiveRecord::Base.connection.execute("DELETE FROM #{YamlDb::Utils.quote_table(table)}")
		end
	end

	def self.load_table(table, data)
		column_names = data['columns']
		truncate_table(table)
		load_records(table, column_names, data['records'])
		reset_pk_sequence!(table)
	end

	def self.load_records(table, column_names, records)
		quoted_column_names = column_names.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }.join(',')
		quoted_table_name = YamlDb::Utils.quote_table(table)
		records.each do |record|
			ActiveRecord::Base.connection.execute("INSERT INTO #{quoted_table_name} (#{quoted_column_names}) VALUES (#{record.map { |r| ActiveRecord::Base.connection.quote(r) }.join(',')})")
		end
	end

	def self.reset_pk_sequence!(table_name)
		if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
			ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
		end
	end
end
