module CountURLs
  module Job
    
    def self.record_domain(domain, source, data_store)
      data_store.threadsafe_operation("counts.csv") do |data|
        records = data.select{|rec| rec[1] == domain}
        if records.length > 0
          records.first[2] += 1
        else
          data << ["jim", source, domain, 1]
        end
      end
    end
    
    def self.get_domain(url)
      url.to_s.gsub("http://", "").gsub("www.", "").split("/").first
    end
    
    class One < BaseJobWithURL    
      def execute(doc, data_store, fields)
        if doc.nil?
          CountURLs::Job::record_domain("couldn't open url", @source, data_store)
          return
        end
        
        doc = Nokogiri::HTML(doc.body)
        
        nodes = doc.css("p.see_job_listing")
        if nodes.length <= 0
          CountURLs::Job::record_domain("link not found", @source, data_store)
        end
      end
      
      def get_children(doc)
        
        @source = "" 
        children = []
          
        if doc.nil?
          return children
        end
        
        doc = Nokogiri::HTML(doc.body)
        
        source_spans = doc.css("span.source")
        @source = if source_spans.length > 0
          source_spans.first.text
        else
          ""
        end
        
        nodes = doc.css("p.see_job_listing")

        if nodes.length > 0
          url = "http://simplyhired.com#{nodes.css("a").first.attr("href")}"
          c = Two.new(url)
          c.source = @source
          children << c
        end
        puts "a"
        children
      end
      
      def document
        agent = Mechanize.new
        page = nil
        begin
          page = agent.get(@url)
        rescue
          puts "problem opening page"
        end
        page
      end
    end
    
    class Two < BaseJobWithURL
      attr_accessor :source
      
      def execute(doc, data_store, fields)
        if doc.nil?
          CountURLs::Job::record_domain("couldn't open url", source, data_store)
          return
        end
        if doc.uri.nil?
          CountURLs::Job::record_domain("doc has no url", source, data_store)
          return
        end
        data_store.add_item("urls.csv", ["jim", doc.uri.to_s])
        CountURLs::Job::record_domain(CountURLs::Job::get_domain(doc.uri), source, data_store)
        puts "."
      end
      def document
        agent = Mechanize.new
        page = nil
        begin
          page = agent.get(@url)
        rescue
          puts "problem opening page"
        end
        page
      end
    end
  end
  
  module Field
  end
  
  FIELDS = {
    "counts.csv" => [
      Class.new(Object) do
        def name
          "source"
        end
      end.new,
      Class.new(Object) do
        def name
          "domain"
        end
      end.new,
      Class.new(Object) do
        def name
          "count"
        end
      end.new
    ],
    "urls.csv" => [
      Class.new(Object) do
        def name
          "url"
        end
      end.new
    ]
  }
  
  START_JOBS = CSV.read('urls.csv').map {|url| CountURLs::Job::One.new(url.first)}
 
end