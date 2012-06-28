module OSCAROrgs
  module Job
    class ExploreLetter < BaseJob
      
      def initialize(letter)
        @letter = letter
      end 
        
      def url
        "http://www.oscar.org.uk/mission_organisations/#{@letter}/"
      end
      
      def get_children(doc)
        items = doc.css("div.directory div.item")
        if items.first.css("p").text.include?("Sorry, there are no entries")
          return []
        end
        items.map{|node| ScrapeResult.new(url, node)}
      end
    end
    
    class ScrapeResult < BaseJobWithURLAndDoc
      include JobMixins::ExecuteScrape
    end
  end
  
  module Field
    class Base
      protected  
      def header_node(doc)
        doc.css("h4").first
      end
      def description_node(doc)
        node = header_node(doc).next
        return nil if node.name == "span" and node.attr("class") == "small"
        node
      end
      def contact_node(doc)
        doc.css("span.small").first
      end
    end
    
    class ContactField < Base
      def scrape(doc)
        header_node = contact_node(doc).css("strong").first
        while header_node
          node = header_node.next
          
          sequence = Class.new(NodeSequence) do
            def ends_sequence?(node)
              node.name == 'strong'
            end
          end.new(node)
          
          if header_node.text.include?(header_name)
            return sequence.to_s
          end
          
          header_node = sequence.last.next
        end
        ""
      end
    end
  end
  
  FIELDS = {
    "oscar_orgs2.csv" => [
      Class.new(Field::Base) do
        def name
          :title
        end
    
        def scrape(doc)
          header_node(doc).text
        end
      end.new,
    
      Class.new(Field::Base) do
        def name
          :description
        end
    
        def scrape(doc)
          Class.new(NodeSequence) do
            def ends_sequence?(node)
              node.name == "span" and node.attr("class") == "small"
            end
          end.new(description_node(doc)).to_s
        end
      end.new,
      
      Class.new(Field::ContactField) do
        def name
          :website
        end
    
        def header_name
          "Website:"
        end
      end.new,
        
      Class.new(Field::ContactField) do
        def name
          :email
        end
    
        def header_name
          "Email:"
        end
      end.new,
      
      Class.new(Field::ContactField) do
        def name
          :telephone
        end
    
        def header_name
          "Tel:"
        end
      end.new
    ]
  }

  START_JOBS = [
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0-9'
  ].map{|letter| Job::ExploreLetter.new(letter)}
 
end