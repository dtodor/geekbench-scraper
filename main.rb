require 'array_ext'
require 'scraper'
require 'db'
require 'chronic'
require 'optparse'


options = {}
 
optparse = OptionParser.new do |opts|
 # Set a banner, displayed at the top
 # of the help screen.
 opts.banner = "Usage: main.rb [options]"

 # Define the options, and what they do
 options[:mode] = "32-bit"
 opts.on( '-p', '--platform [32-bit|64-bit]', 'Platform: 32-bit or 64-bit' ) do |p|
   if p == "32-bit" or p == "64-bit"
     options[:mode] = p
   end
 end

 # This displays the help screen, all programs are
 # assumed to have this option.
 opts.on( '-h', '--help', 'Display this screen' ) do
   puts opts
   exit
 end
end
 
# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

puts "Parsing Geekbench scores for #{options[:mode]} plattform ..."

configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/configurations.yml'))

results = {}
configurations.each do |key,value|
  results[key] = Scraper.scrape :search => value['search'], :processor => Regexp.new(value['processor']), :plattform => options[:mode]
end

Score.delete_all

results.each do |key,scores|
  scores.each do |score|
    processor = configurations[key]['name']
    
    match = Score.first :conditions => ["processor = ? and score = ? and relative_time = ?", processor, score[:score], score[:time]]
    
    unless match
      s = Score.new
      s.processor = processor
      s.relative_time = Chronic.parse score[:time]
      s.score = score[:score]
      if !s.save
        puts "Unable to persist new record: [#{s.processor}, #{s.score}, #{s.relative_time}]"
      end
    end
  end
end

average_scores = Score.average(:score, :group => :processor, :order => :score)
average_scores.each do |processor, avg_score|
  puts "#{processor} => #{avg_score}"
end

