class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |var_name|
      define_method(var_name) do 
        instance_variable_get("@#{var_name}")
      end
      define_method("#{var_name}=") do |val|
        instance_variable_set("@#{var_name}", val)
      end
    end
  end
end
