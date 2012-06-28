class BaseJob
  def document
    doc = nil
    begin
      doc = Nokogiri::HTML(open(url))
    rescue
      puts "problem opening uri"
    end
    doc
  end
  
  def execute(doc, data_store, fields)
  end
  
  def get_children(doc)
    []
  end
end

class BaseJobWithURL < BaseJob
  attr_accessor :url
  def initialize(url)
    @url = url
  end
end

class BaseJobWithDoc < BaseJob
  attr_accessor :document
  def initialize(doc)
    @document = doc
  end
end

class BaseJobWithURLAndDoc < BaseJob
  attr_accessor :url
  attr_accessor :document
  
  def initialize(url, doc)
    @url = url
    @document = doc
  end
end

module JobMixins  
  module ExecuteScrape
    def execute(doc, data_store, fields)
      return if !doc
      fields.each_pair do |k, v|
        scraped_record = v.map{|f| f.scrape(doc)}
        next if skip?(k, scraped_record, data_store, fields) 
        data_store.add_item(k, [url] + scraped_record)
      end
    end
    
    protected 
    
    def skip?(key, scraped_record, data_store, fields)
      false
    end
    
    def record_exists?(target_key, id_column, key, fields, scraped_record, data_store)
      return false unless key == target_key
      index = fields[key].map{|f| f.name.to_s}.index(id_column.to_s)
      data_store.get_items(key).each do |record|
        return true if (record[index + 1]) == scraped_record[index]  
      end
      false
    end
    
  end
end