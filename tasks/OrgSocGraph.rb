require 'mysql'

module OrgSocGraph
  FIELDS = {
    "orgs.csv" => [
      Class.new(Object) do
        def name
          :description
        end
     end.new,
    ]
  }
 
  START_JOBS = [
    Class.new(BaseJob) do
      def url
        'http://www.example.com/'
      end
      
      def get_children(doc)
        # do MySQL query to get the URLs of the child jobs
        dbh = Mysql.real_connect("216.93.247.46", "turb_mi5", "db-fastlane", "techmi5_socgraph")
        # limit to 10 for test run
        res = dbh.query('SELECT website_url FROM tbl_organizations WHERE website_url != ""')
        children = []
        while row = res.fetch_hash do
          children << Class.new(BaseJobWithURL) do         
             def execute(doc, data_store, fields)
                # handle if the URL can't be opened
                if doc.nil? 
                  return
                end
                title = doc.css("title").text
                meta_desc = doc.css("meta[name='description']")
                if(!meta_desc.empty?)
                  data_store.add_item("orgs.csv", [
                     self.url,
                     # crawl for meta description
                    meta_desc[0]['content']
                  ])
                else
                  data_store.add_item("orgs.csv", [
                   self.url,
                    # just put in the title
                    title
                  ])
                 end
             end
         end.new(row["website_url"]) 
      end
      children  
    end
  end.new
]
end
