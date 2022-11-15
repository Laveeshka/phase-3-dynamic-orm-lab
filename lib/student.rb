require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

    #creates attr_accessors for each column name
    self.column_names.each do |col_name|
        attr_accessor col_name.to_sym
    end

end
