module XKCD
  FIELDS = {
    "xkcd.csv" => [
      Class.new(Object) do
        def name
          :title
        end
     end.new,
      Class.new(Object) do
        def name
          :url
        end
      end.new(),
      Class.new(Object) do
        def name
          :image_url
        end
      end.new
    ]
  }
 
  START_JOBS = [
    Class.new(BaseJob) do
      def url
        'http://xkcd.com/archive'
      end
 
      def get_children(doc)
        doc.css('#middleContainer > a').map{|a| "http://xkcd.com#{a.attr('href')}"}.map do |url|
          Class.new(BaseJobWithURL) do
            def execute(doc, data_store, fields)
              url_node = doc.css("ul.comicNav").last.next.next
              image_url_node = url_node.next.next
 
              data_store.add_item("xkcd.csv", [
                self.url,
                doc.css("#ctitle").text,
                url_node.text.split(" ").last,
                image_url_node.text.split(" ").last
              ])
            end
          end.new(url)
        end
      end
    end.new
  ]
end
