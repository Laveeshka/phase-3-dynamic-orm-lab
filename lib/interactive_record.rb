require_relative "../config/environment.rb"
require "active_support/inflector"

class InteractiveRecord

  #creates a downcased, plural table name based on the Class name
  def self.table_name
    self.to_s.downcase.pluralize
  end

  #returns an array of SQL column names
  def self.column_names
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |row|
      column_names << row["name"]
    end

    #get rid of any nil values that may end up in our collection
    column_names.compact
  end

  #creates a new student with attributes
  def initialize(options = {})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  #return the table name when called on an instance of Student
  def table_name_for_insert
    self.class.table_name
  end

  #return the column names when called on an instance of Student
  #does not include an id column
  def col_names_for_insert
    col_names = self.class.column_names.delete_if do |col_name|
      col_name == "id"
    end
    #we need column names in the format "col1, col2, col3, ..." for the INSERT statement
    col_names.join(", ")
  end

  #formats the values to be used in a SQL statement
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
        unless send(col_name).nil?
            values << "'#{send(col_name)}'"
        end
    end
    values.join(", ")
  end

  #saves the student to the db
  #sets the student's id
  def save
    sql = <<-SQL
        INSERT INTO #{table_name_for_insert} 
        (#{col_names_for_insert}) 
        VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  #executes the SQL to find a row by name
  def self.find_by_name(name)
    sql = <<-SQL
        SELECT * 
        FROM #{self.table_name} 
        WHERE name = ? 
        LIMIT 1
    SQL
    DB[:conn].execute(sql, name)
  end

  #executes the SQL to find a row by the attribute passed into the method
  #accounts for when an attribute value is an integer
  def self.find_by(attribute)
    sql = <<-SQL
        SELECT * 
        FROM #{self.table_name} 
        WHERE #{attribute.keys.first} = ?
        LIMIT 1
    SQL
    DB[:conn].execute(sql, attribute.values.first)
  end

end
