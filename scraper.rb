require "open-uri"
require "nokogiri"
require "cgi"

class Scraper
  
  @@base_url = 'http://browse.geekbench.ca'
  @@max_pages = 10

  def self.scrape(config={})
    page = 1
    results = []
    pattform_regex = Regexp.new(".+(Mac OS X).+(#{config[:plattform]})")
    url = "/geekbench2/search?q=#{CGI.escape(config[:search])}"
    begin
      doc = Nokogiri::HTML(open("#{@@base_url}#{url}"))
      doc.css('td.overall-score').each do |t|
        system = t.parent.next_sibling.next_sibling.next_sibling.children.first.text
        submit_time = t.parent.css('span.submit-time').first.text.strip
        processor = t.parent.next_sibling.next_sibling.children.first.text
        
        if system =~ pattform_regex and processor =~ config[:processor]
          results << {:time => submit_time, :score => t.text.to_i}
        end
      end
      nextPageNode = doc.css('div.pagination a.next_page').first
      page += 1
      if !nextPageNode.nil? and page <= @@max_pages
        url = nextPageNode.attribute('href')
      else
        url = nil
      end
    end while url
    results
  end
end
