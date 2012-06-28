module Template
  module Job
    class ExampleJob
      def get_document
      end
      
      def get_children(doc)
      end
      
      def execute(doc, dataStore)
      end
    end
  end
  
  module Helpers
    class ExampleHelper
    end
  end
  
  FIELDS = [
    # Array of objects...
    # Each object must implement name()
    # You probably also want to implement scrape()
  ]
  
  START_JOBS = [
    
  ]
end