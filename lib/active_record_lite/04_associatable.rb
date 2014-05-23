require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.to_s.constantize
  end

  def table_name
    class_name.to_s.downcase + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    belongings = {
      foreign_key: "#{name.to_s.underscore}_id".to_sym,
      class_name: name.to_s.singularize.camelcase.to_s,
      primary_key: :id
    }
   
    belongings = belongings.merge options
    belongings.each { |k, v| self.instance_variable_set("@#{k}", v)}
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    things_to_have = {
      foreign_key: (self_class_name.underscore + "_id").to_sym,
      class_name: name.to_s.singularize.camelcase.to_s,
      primary_key: :id
    }
    
    things_to_have = things_to_have.merge options
    things_to_have.each { |k, v| self.instance_variable_set("@#{k}", v) }
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    
    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      class_name = options.model_class
      
      h = { options.primary_key =>  foreign_key}
      found_object = class_name.where(h)
      (found_object).first
       
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      foreign_key = self.send(options.primary_key)
      class_name = options.model_class
  
      h = { options.foreign_key => foreign_key }
      class_name.where(h)
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
