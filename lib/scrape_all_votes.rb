require_relative 'get_page'
require_relative 'read_file'
require 'base32'

require_relative 'get_mps'

class GetAllVotes
  def self.votes(url, cadent)

     file_path = "http://www.lutskrada.gov.ua#{url}"
     p file_path
     file_names = []
     file_name = "#{File.dirname(__FILE__)}/../files/download/#{Base32.encode(file_path)}"
     if (!File.exists?(file_name) || File.zero?(file_name))
          puts ">>>>  File not found, Downloading...."
          File.write(file_name, open(file_path).read)
          p "end load"
     end
      `unzip -o -O cp866 #{file_name} -d #{file_name}_D/`
      files = `cd #{file_name}_D && ls`

      files.split(/\n/).each do |d|
         `cd #{file_name}_D/#{d.gsub(/\s/,'\ ')} && ls`.split(/\n/).each do |rtf|
            next if rtf == "AllGOLOS.rtf"
            file_names << "#{file_name}_D/#{d}/#{rtf}"
         end
      end
     file_names.each_with_index do |file_name, i|

        ReadFile.new.rtf(file_name).each do |vot|
          p vot
           event = VoteEvent.first(name: vot[:name], date_vote: vot[:datetime], date_caden: cadent, rada_id: 3, option: vot[:res])
           if event.nil?
             events = VoteEvent.new(name: vot[:name], date_vote: vot[:datetime], number: i + 1, date_caden: cadent, rada_id: 3, option: vot[:res])
             events.date_created = Date.today
             events.save
           else
             events = event
             events.votes.destroy!
           end
           vot[:voteds].each do |v|
             next if v.empty?
             next if v.first == "міський голова"
             vote = events.votes.new
             vote.voter_id = $all_mp.serch_mp(v.first)
             vote.result = short_voted_result(v.last)
             vote.save
           end
        end
     end
  end
  def self.short_voted_result(result)
    hash = {
        "НЕ ГОЛОСУВАВ":  "not_voted",
        відсутній: "absent",
        ПРОТИ:  "against",
        ЗА: "aye",
        УТРИМАВСЯ: "abstain"
    }
    hash[:"#{result}"]
  end
end