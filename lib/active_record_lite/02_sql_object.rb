require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    cats = results.map { |el|  self.new(el)   }
  end
end

class SQLObject < MassObject
  def self.columns
    cols = DBConnection.execute2("SELECT * FROM #{self.table_name}").first
    cols.map(&:to_sym).each do |col_name|
      define_method("#{col_name}=") do |val|
        self.attributes[col_name] = val
      end
      define_method(col_name) do
        self.attributes[col_name]
      end
    end
  end

  def self.table_name=(table_name)
    self.instance_variable_set("@table_name", table_name)
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    sql = (<<-SQL)
    
    SELECT *
    FROM #{self.table_name}
    
    SQL
   
    object_parts = DBConnection.execute(sql)
    object_parts.map { |parts| self.new(parts) }
  end

  def self.find(id)
    object_parts = DBConnection.execute(<<-SQL)
    
    SELECT * 
    FROM #{self.table_name}
    WHERE (id = #{id})
    LIMIT 1
    SQL
    
    self.parse_all(object_parts).first
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    col_names = self.attributes.keys.join(", ")
    question_marks = (["?"] * self.attributes.keys.count).join(", ")
    DBConnection.execute(<<-SQL, self.attribute_values) 
    
    INSERT INTO #{self.class.table_name}
     (#{col_names})
    VALUES
    (#{question_marks})

    SQL
    self.attributes[:id] = DBConnection.last_insert_row_id
  end

  def initialize(params={})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      raise "Invalid Column!" unless self.class.columns.include? attr_name
      self.attributes[attr_name] = value
    end
  end

  def save
    attributes[:id].nil? ? insert : update
  end

  def update
    col_line = self.attributes.map { |attr, val| "#{attr} = ?"}.join(", ")
    
    DBConnection.execute(<<-SQL, self.attribute_values)
    
    UPDATE #{self.class.table_name}
    SET
    #{col_line}
    WHERE
    id = #{self.id}
    
    SQL
  end

  def attribute_values
    self.attributes.map { |k, v| self.send(k) }
  end
end
