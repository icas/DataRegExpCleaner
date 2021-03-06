require 'csv'
class DataRegExpCleaner

  CLEANER_METHOD_SUFFIX = "_regexp_cleaner"
  DATA_DIRECTORY = "data"
  @@all_fields = Hash.new{ |hash,key| hash[key] = [] }

  def initialize
     puts " initialize class #{self.class}"
     self.class.module_eval( "def #{self.class}.get=(id) yield end" )
  end

   
  def self.regexp_cleaner(field_name, regexp)
    @@all_fields[:"#{self}"].push(field_name)

    send(:define_method, "#{field_name}#{CLEANER_METHOD_SUFFIX}"){ | value |
      if regexp.match(value.to_s)  
        field_value_cleaned = value.to_s.gsub( regexp , "")  
        send( "#{field_name}=", field_value_cleaned)  
      end
    }
  end

  def save
    fields = @@all_fields[:"#{self.class}"]
    clean_fields ( fields )
    save_in_file 
  end

  def update
     fields = @@all_fields[:"#{self.class}"]
     clean_fields ( fields )
     # update_in_file

  end
  
  def self.get ( id )
    puts  "Find the objet with id: #{id}"
    data = find_in_file ( id )
  end


  def clean_fields( fields )
    fields.each do |field_name|
      send("#{field_name}#{CLEANER_METHOD_SUFFIX}", send("#{field_name}"))
    end
  end

  def save_in_file
    file_name = "#{DATA_DIRECTORY}/#{self.class.name}.csv" 
    data = extract_data 
    if !self.class.get ( data.first )
      CSV.open( file_name , "a") do |csv|
        csv << data 
      end
      puts " #{self}  ...saved "
    end
  end

  def extract_data
    fields = @@all_fields[:"#{self.class}"]
    data = []
     fields.each do |field_name|
        data << send("#{field_name}")
      end
    data
  end

  def self.find_in_file ( id )
    instance = nil
    file_name = "#{DATA_DIRECTORY}/#{self.to_s}.csv" 

    if File.exist?(file_name) 
        CSV.foreach( file_name , "r") do |row|
          if (row.first == id.to_s )
            instance = self.parse_instance ( row )
          end
      end
    end
    instance
  end

  def self.parse_instance ( data )
    instance = self.new
    fields = @@all_fields[:"#{self.to_s}"]
    
    fields.each_with_index do |field_name, index|
      # puts " Asignee in a instance of #{instance}, field : #{field_name} =>  #{data[index]} "
      instance.send( "#{field_name}=", data[index])  
    end
    instance
  end

  def update_in_file 
  end

end





