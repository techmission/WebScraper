module CMF
  module Job
    class ExploreIndex < BaseJob
      def url
        "http://www.cmf.org.uk/international/jobs.asp?page=#{page}"
      end
      
      def get_children(doc)
        children = []
        p = doc.css('div#sitecolumnrpadding > h2').first.next_element
        while p.name == 'p'
          url = 'http://www.cmf.org.uk' + p.css('a').first.attr('href')
          children << ScrapeResult.new(url)
          p = p.next_element;
        end
        children
      end
    end
    
    class ScrapeResult < BaseJobWithURL
      include JobMixins::ExecuteScrape  
    end
  end
  
  module Field
    class Base
      def scrape(doc)
        scrape_to_map(doc)[name] || ''
      end
      protected 
      def scrape_to_map(doc)
        map = {}
        header = doc.css('div#sitecolumnrpadding > h2').first;
            map[:title] = header.text
            node = header
            while node.name != 'strong'
              node = node.next
            end
            node = node.next 
            map[:location] = node.text
             
            contact_header = node
            while contact_header and contact_header.name != 'strong'
              contact_header = contact_header.next
            end
             
            if contact_header 
              map[:contact_name] = contact_header.next.text;
              node = contact_header.next().next();
              while node
                if node.text.strip.length > 0
                  if node.text.include?('Email:')
                    map[:contact_email] = node.text.split('Email:').last
                  elsif node.text.include?('Website:')
                    map[:contact_website] = node.text.split('Website:').last
                  elsif node.text.include?('Tel:')
                    map[:contact_telephone] = node.text.split('Tel:').last
                  elsif node.name != 'br'
                    break
                  end
                end
                node = node.next
              end
            else
              node = node.next
            end
            
            map[:description] = ''
            while node
              map[:description] << node.text
              node = node.next
            end
            
            map
      end
    end
  end
  
  FIELDS = {
    "cmf_opps.csv" => [ 
      Class.new(Field::Base) do
        def name
          :title
        end
      end.new,
      Class.new(Field::Base) do
        def name
          :description
        end
      end.new,
      Class.new(Field::Base) do
        def name
          :location
        end
      end.new,
      Class.new(Field::Base) do
        def name
          :contact_name
        end
      end.new,
      Class.new(Field::Base) do
        def name
          :contact_email
        end
      end.new,
      Class.new(Field::Base) do
        def name
          :contact_website
        end
      end.new,
      Class.new(Field::Base) do
        def name
          :contact_telephone
        end
      end.new
    ]
  }
  
  START_JOBS = [
    Class.new(Job::ExploreIndex) do
      def page 
        'short' 
      end
    end.new,
      
    Class.new(Job::ExploreIndex) do
      def page 
        'med' 
      end     
    end.new,
      
    Class.new(Job::ExploreIndex) do
      def page 
        'long' 
      end
    end.new
  ]
end