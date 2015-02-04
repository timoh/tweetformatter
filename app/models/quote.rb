class Quote
  include Mongoid::Document
  include Mongoid::Timestamps

  field :stock_symbol, type: String
  field :bid_price, type: Float
  field :timestamp, type: DateTime
  field :quote_payload, type: Hash

  belongs_to :company

  validates_presence_of :stock_symbol, :bid_price, :timestamp, :quote_payload


  def self.all_companies # return list of companies that have quotes
  	all_companies = []
  	all_companies = self.all.distinct(:stock_symbol)
  	return all_companies
  end

  def self.timestamps_sorted
  	timestamps = Quote.all.distinct(:timestamp)
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

  def self.calculate_average_bid_for_company(timestamp, company)
  	# timestamp ==> find all values within 10 minutes 
  	# company ==> stock_symbol

  	# return ==> average of all values

  	companies = Quote.where(:stock_symbol => company.to_s)

  	quotes_lower_filtered = companies.where(:timestamp.gte => (timestamp-(5.minutes)).to_s)
  	quotes_higher_filtered = quotes_lower_filtered.where(:timestamp.lte => (timestamp+(5.minutes)).to_s)

  	all_matching_quotes = quotes_higher_filtered
  	
  	if all_matching_quotes.size <= 0
  		return 0.0
  	end

  	sum_bids = 0
  	anomalies = 0

  	all_matching_quotes.each do |quote|
  		if quote.bid_price > 0
  			sum_bids = sum_bids + quote.bid_price 
  		else
  			anomalies = anomalies + 1
  		end
  	end

  	average_value = (sum_bids.to_f / (all_matching_quotes.count - anomalies).to_f).to_f
  	return_value = average_value.to_f.round(2)

  	if return_value <= 0  
  		return nil
  	else 
  		return return_value
  	end 
  end

  def self.find_company_value_by_timestamp(timestamp, company)
  	cvalue = Quote.calculate_average_bid_for_company(timestamp, company)
  	return cvalue
  end

  def self.generate_stock_csv

  	require 'csv'

  	file_path = Dir.pwd + '/public/stock_quotes.csv'
    CSV.open(file_path, "wb") do |csv|

    	puts "Creating CSV output at #{file_path.to_s}"

    	header_row = []
    	header_row << "Timestamp"

    	rest_of_header_row = Quote.all_companies.to_a.sort

    	#puts rest_of_header_row.to_s

    	header_row = header_row + rest_of_header_row

    	puts "Header row: #{header_row.to_s}"
    	csv << header_row

    	timestamps_sorted = Quote.timestamps_sorted

    	timestamps_sorted.each do |ts|
    		# puts "Creating row for timestamp #{ts.to_s(:short)}"
    		row = []
    		row << ts.to_s(:short)
    		Quote.all_companies.sort.each do |company|
	    		# then append values by iterating over sorted companies
	    		# find company value average by timestamp (ts)
	    		row << Quote.find_company_value_by_timestamp(ts, company)
    		end

    		# append whole row to CSV file
    		csv << row

    		puts "#{row.to_s}"
    	end
    end

    return true
  end

end