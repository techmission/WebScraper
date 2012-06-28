module OSCAR 
  module Job
    class ExploreIndex < BaseJob      
      def url
        "http://www.oscar.org.uk/vacancies.php?main_category=0&location_category=0&keyword=Keyword&activity_category=0&age_category=0&submit=Search"
      end
      
      def get_children(doc)
        children = []
        links = doc.css('div.vacancy_summary span.summary a')
        links.each do |link|
          next unless link.text.include?("more »")
          href = link.attr('href')
          url = "http://oscar.org.uk#{href[1,href.length-1]}"
          children << ScrapeResult.new(url) if doc  
        end
        children
      end
    end
    
    class ScrapeResult < BaseJobWithURL
      include JobMixins::ExecuteScrape
      protected
      def skip?(key, scraped_record, data_store, fields)
        record_exists?("oscar_org.csv", :org_title, key, fields, scraped_record, data_store)
      end
    end
  end
  
  module Field
    class Base
      protected  
      def main_header_node(doc)
        doc.css('div.vacancy_summary > h4').first
      end
      
      def org_header_node(doc)
        doc.css('div.item > h4').first
      end
    end
      
    class OrgField < Base  
      def scrape(doc)
        node = org_header_node(doc).next_element.next
        
        while node
          if node.name = 'p' and node.attr('class') == 'small'
            header = node.css('strong').first
            while header
              n = header.next
              break unless n
             
              node_sequence = Class.new(NodeSequence) do
                def ends_sequence?(node)
                  node.name == 'strong'
                end
              end.new(n)
                  
              return node_sequence.to_s if header.text.include?(header_name)
                    
              header = nil
              unless node_sequence.to_node_set.empty?
                header = node_sequence.to_node_set.last.next
              end
            end
          end
        
          node = node.next
        end
      end
      '' 
    end
  end
  
  OPP_FIELDS = [
    Class.new(Field::Base) do
      def name
        :title
      end
  
      def scrape(doc)
        main_header_node(doc).text
      end
    end.new,
  
    Class.new(Field::Base) do
      def name
        :description
      end
  
      def scrape(doc)
        Class.new(NodeSequence) do
          def ends_sequence?(node)
            node.name == "div" and node.attr("id") == "images"
          end
        end.new(main_header_node(doc).next.next.next).to_s
      end
    end.new
  ]
  
  ORG_FIELDS = [
    Class.new(Field::Base) do
      def name
        :org_title
      end
    
      def scrape(doc)
        org_header_node(doc).text
      end
    end.new,
    
    Class.new(Field::Base) do
      def name
        :org_description
      end
    
      def scrape(doc)
        org_header_node(doc).next_element.text
      end
    end.new,
    
    Class.new(Field::OrgField) do
      def name
        :org_address
      end
    
      def header_name
        "Address:"
      end
    end.new,
    
    Class.new(Field::OrgField) do
      def name
        :org_telephone
      end
    
      def header_name
        "Tel:"
      end
    end.new,
    
    Class.new(Field::OrgField) do
      def name
        :org_email
      end
    
      def header_name
        "Email:"
      end
    end.new,
    
    Class.new(Field::OrgField) do
      def name
        :org_website
      end
    
      def header_name
        "Web Address:"
      end
    end.new,
    
    Class.new(Field::OrgField) do
      def name
        :org_fax
      end
    
      def header_name
        "Fax:"
      end
    end.new
  ]
  
  FIELDS = {
    "oscar_opps.csv" => OPP_FIELDS + ORG_FIELDS#,
    #"oscar_orgs.csv" => ORG_FIELDS
  }

  START_JOBS = [Job::ExploreIndex.new]
end