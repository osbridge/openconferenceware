namespace :export do
  task :speakers => :environment do
    speakers = Proposal.confirmed.populated.map(&:users).flatten.sort_by(&:last_name).uniq

    CSV::Writer.generate(File.open('speakers.csv','w')) do |csv|
      fields = [
        :first_name,
        :last_name,
        :affiliation,
        :email
      ]
      csv << fields.map{|field| field.to_s}
      for speaker in speakers
        csv << fields.map{|field| value = speaker.send(field) }
      end
    end
  end
end