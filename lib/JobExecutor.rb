class JobExecutor
  
  attr_reader :data_store, :fields
  
  def initialize(fields)
    @jobs = []
    @threads_working = 0
    @lock = Mutex.new
    @data_store = DataStore.new(fields)
    @fields = fields
  end
  
  def run(options = {})
    options[:nthreads] ||= 50
    
    for i in 1..options[:nthreads] do
      (Thread.new {run_thread}).join
    end
  end
  
  def add_jobs(jobs)
    locked_operation { jobs.each { |j| @jobs.push(j)} }
  end
  
  private
  
  def run_thread
    finished_job = false
    while j = get_next_job(finished_job)
      doc = j.document
      add_jobs(j.get_children(doc))
      j.execute(doc, @data_store, @fields)
      finished_job = true
    end
  end
  
  def get_next_job(finished_job)
    locked_operation do
      @threads_working -= 1 if finished_job
      return nil unless @jobs.length + @threads_working
      @threads_working += 1
      @jobs.shift
    end
  end
  
  def locked_operation
    @lock.lock
    ret = yield
    @lock.unlock
    ret
  end
end