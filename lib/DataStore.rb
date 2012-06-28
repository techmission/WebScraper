class DataStore
  
  def initialize(fields)
    @data = Hash[ fields.keys.map{|f| [f, []]} ]
    @lock = Mutex.new
  end
  
  def add_item(key, item)
    threadsafe_operation(key) { |data| data << item }
  end
  
  def get_items(key=nil)
    threadsafe_operation(key) { |data| data }
  end  
  
  def threadsafe_operation(key=nil)
    @lock.lock
    data = (key.nil? ? @data : @data[key]) 
    ret = yield data
    @lock.unlock
    ret
  end
end