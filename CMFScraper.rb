require 'open-uri'
require 'nokogiri'
require 'csv'
require './Crawler.rb'

module ExploreCMFIndex 
  def getDocument
    Nokogiri::HTML(open("http://www.cmf.org.uk/international/jobs.asp?page=#{self.page}"))
  end
  
  def getChildren(doc) 
    children = []
    p = doc.css('div#sitecolumnrpadding > h2').first.next_element
    while p.name == 'p'
      url = 'http://www.cmf.org.uk' + p.css('a').first.attr('href')
      doc = Nokogiri::HTML(open(url))
      children << ScrapeCMFResult.new(doc) if doc
      p = p.next_element;
    end
    return children; 
  end
  
  def execute(doc, dataStore)
  end
end

class ExploreCMFShortTerm
  include ExploreCMFIndex
  def page 
    'short' 
  end
end

class ExploreCMFOneYear
  include ExploreCMFIndex
  def page
    'med'
  end
end

class ExploreCMFLongTerm
  include ExploreCMFIndex  
  def page
    'long'
  end
end

class ScrapeCMFResult
    
  def initialize(doc) 
    @doc = doc;
  end
    
  def getDocument() 
    return @doc;
  end
    
  def execute(doc, data_store) 
    return if !@doc
      
    header = @doc.css('div#sitecolumnrpadding > h2').first;
    title = header.text
    node = header
    while node.name != 'strong'
      node = node.next
    end
    node = node.next 
    location = node.text
     
    contact_header = node
    while contact_header and contact_header.name != 'strong'
      contact_header = contact_header.next
    end
     
    contact_name = ''
    contact_email = ''
    contact_website = ''
    contact_telephone = ''
    if contact_header 
      contact_name = contact_header.next.text;
      node = contact_header.next().next();
      while true
        if node.text.strip
          if node.text.include?('Email:')
            contact_email = node.text.split('Email:').last
          elsif node.text.include?('Website:')
            contact_website = node.text.split('Website:').last
          elsif node.text.include?('Tel:')
            contact_telephone = node.text.split('Tel:').last
          elsif node.name != 'br'
            break
          end
          
          node = node.next
          break if !node
        end
      end
    else
      node = node.next
    end
    
    description = ''
    while node
      description += node.text
      node = node.next
    end
        
    r = [title, location, contact_name, contact_email, contact_website, contact_telephone, description]
    data_store.add_item(r)
  end
  
  def getChildren(doc)
    []
  end
end

c = Crawler.new
c.add_jobs([ExploreCMFShortTerm.new, ExploreCMFOneYear.new, ExploreCMFLongTerm.new])
c.run

CSV.open("cmf_scrape.csv", "wb") do |csv|
  csv << ['title', 'location', 'contact_name', 'contact_email', 'contact_website', 'contact_telephone', 'description']
  for r in c.data_store.get_items do
    csv << r
  end
end