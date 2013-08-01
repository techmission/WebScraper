# for compatibility with 1.8.x require rubygems
require 'rubygems'
require 'open-uri'
# 1.8.x requires <= 1.5.0 of Nokogiri
require 'nokogiri'
require 'csv'
require 'mechanize'
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/tasks/*.rb'].each {|file| require file }

ARGV.each do |mod| 
  jobs = eval("#{mod}::START_JOBS")
  fields = eval("#{mod}::FIELDS")
  
  je = JobExecutor.new(fields)
  je.add_jobs(jobs)
  je.run
  
  fields.each_pair do |file, columns|
    CSV.open("output/#{file}", "wb") do |csv|
      csv << ['source_url'] + columns.map{|c| c.name.to_s}
      for record in je.data_store.get_items(file)
        csv << record.map{|r| HTMLCleaning::clean(r.to_s, :convert_to_plain_text => true)}
      end
    end
  end
end