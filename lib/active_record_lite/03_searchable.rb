require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    
    where_line = params.keys.map { |attr| "#{attr} = ?"}.join(" AND ")
    object_parts = DBConnection.instance.execute(<<-SQL, params.values)
    
    SELECT * 
    FROM #{self.table_name}
    WHERE
    #{where_line}
    
    
    SQL
    
    self.parse_all(object_parts)
    
  end
end

class SQLObject
  extend Searchable
end
