require_relative 'get_page'
#require_relative 'scrape_all_votes'
require_relative 'get_mps'
#require_relative 'voted'

class GetPages
  def initialize
    @all_page = []
    $all_mp = GetMp.new
    #@vot_seved =  VoteEvent.all(:fields => [:date_caden], :order => [:date_caden]).map{|v| v.date_caden}.uniq
    url = "https://www.lutskrada.gov.ua/pages/rezuaty-holosuvan-zasidan-sesii"
    page = GetPage.page(url)
    page.css('.c-text p').each do |p|
      next if p.css('a').empty?
      p p.css('a')[0][:href].gsub('https://www.lutskrada.gov.ua', '')
      p p.text[/\(.+\)/].gsub(/(\(|\))/,'')
      @all_page << { cadent: p.text[/\(.+\)/].gsub(/(\(|\))/,''), url: p.css('a')[0][:href].gsub('https://www.lutskrada.gov.ua', '') }
    end
  end
  def get_all_votes
    @all_page.each do |p|
      next if @vot_seved.include?(p[:cadent])
      p p[:cadent]
      GetAllVotes.votes(p[:url], p[:cadent])
    end
  end
end
GetPages.new