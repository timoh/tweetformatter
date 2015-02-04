class TenMinCount
  include Mongoid::Document

  field :timestamp, type: DateTime
  field :company_symbol, type: String
  field :count, type: Integer

  validates_uniqueness_of :company_date

  def company_date
    return self.date.to_s + self.company_symbol.to_s
  end

  def self.all_companies # return list of companies that have quotes
    all_companies = []
    all_companies = Quote.all.distinct(:stock_symbol)
    return all_companies
  end

  def self.timestamps_sorted
    timestamps = Tweet.all.distinct(:datetime)
    puts timestamps.to_s
    timestamps_sorted = timestamps.sort

    ts_first = timestamps_sorted.first
    ts_last = timestamps_sorted.last
    current_ts = ts_first

    array_of_timestamps = Array.new
    while current_ts <= (ts_last + 10.minutes) do
      array_of_timestamps << current_ts
      current_ts = current_ts + 10.minutes
    end
    array_of_timestamps = array_of_timestamps.sort

    return array_of_timestamps
  end

  def self.count_mentions_for_company(timestamp, company)
    # timestamp ==> find all values within 10 minutes 
    # company ==> stock_symbol

    # return ==> average of all values

    tweets_filtered_by_cmp = Tweet.where(:text => /#{company}/)
    # tweets_filtered_by_cmp = Array.new
    # all_tweets.each do |tweet|
    #   if tweet.text.include? company
    #     tweets_filtered_by_cmp << tweet
    #   end
    # end

    tweets_lower_filtered = tweets_filtered_by_cmp.where(:datetime.gte => (timestamp-(5.minutes)).to_s)
    tweets_higher_filtered = tweets_lower_filtered.where(:datetime.lte => (timestamp+(5.minutes)).to_s)

    all_matching_tweets = tweets_higher_filtered
    
    if all_matching_tweets.size >= 0
     return all_matching_tweets.size
    else
     return 0
    end

  end

  def self.generate_tweet_csv # uses Quote timestamps!

    require 'csv'

    file_path = Dir.pwd + '/public/tweet_mentions.csv'
    CSV.open(file_path, "wb") do |csv|

      puts "Creating CSV output at #{file_path.to_s}"

      header_row = []
      header_row << "Timestamp"

      rest_of_header_row = TenMinCount.all_companies.to_a.sort

      #puts rest_of_header_row.to_s

      header_row = header_row + rest_of_header_row

      puts "Header row: #{header_row.to_s}"
      csv << header_row

      timestamps_sorted = Quote.timestamps_sorted

      timestamps_sorted.each do |ts|
        # puts "Creating row for timestamp #{ts.to_s(:short)}"
        row = []
        row << ts.to_s(:short)
        TenMinCount.all_companies.sort.each do |company|
          # then append values by iterating over sorted companies
          # find company value average by timestamp (ts)
          row << TenMinCount.count_mentions_for_company(ts, company)
        end

        # append whole row to CSV file
        csv << row

        puts "#{row.to_s}"
      end
    end

    return true
  end
  
end