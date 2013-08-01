module DMOZ
  FIELDS = {
    "dmoz.csv" => [
      Class.new(Object) do
        def name
          :title
        end
     end.new,
      Class.new(Object) do
        def name
          :url
        end
      end.new
    ]
  }
 
  START_JOBS = [
    Class.new(BaseJob) do
      def url
        'http://www.dmoz.org/Arts/Television/Networks/PBS/'
      end
      
      def execute(doc, data_store, fields)
         data_store.add_item("dmoz.csv", [
           self.url,
           doc.css(".directory-url li a")[0].text,
           doc.css(".directory-url li a")[0]['href']
         ])
      end
    end.new
  ]
end
