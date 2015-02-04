class Fetcher

  def self.read_tweets
    require 'json'

    counter = 0 

    File.open("/vagrant/Code/js/tweets/tweets.json", "r") do |f|
      f.each_line do |line|
        counter = counter + 1
        Fetcher.persist_tweets([JSON.parse(line)])

        puts counter if counter % 50 
      end
    end

    return 
  end

  def self.fetch_tweets
    require 'net/http'
    json = Net::HTTP.get('tweetextractor.herokuapp.com', '/')

    require 'json'
    tweets = JSON.parse(json)

    return tweets
  end

  def self.fetch_stocks
    require 'net/http'
    json = Net::HTTP.get('stockcollector.herokuapp.com', '/')

    require 'json'
    stocks = JSON.parse(json)

    return stocks
  end

  def self.persist_tweets(tweets)
    raise 'Tweets is empty' if tweets == nil

    tweets.each do |tw|
      new_t = Tweet.new
        # field :tweet_id, type: String
        # field :text, type: String
        # field :screen_name, type: String
        # field :datetime, type: DateTime
        # field :tweet_payload, type: Hash

      new_t.tweet_id = tw["id"]
      new_t.text = tw["text"]
      new_t.screen_name = tw["user"]["screen_name"]
      new_t.datetime = DateTime.parse(tw["created_at"])
      new_t.tweet_payload = tw

      new_t.save
    end

    return tweets.size
  end

  def self.persist_stocks(stocks)
    raise 'Stocks is empty' if stocks == nil

      # field :stock_symbol, type: String
      # field :bid_price, type: Float
      # field :timestamp, type: DateTime
      # field :quote_payload, type: Hash
      # belongs_to :company

    stocks.each do |st|
      q = Quote.new

      stock_symbol = st['symbol']
      ts = DateTime.strptime(st['created_at'], "%FT%T").to_s
      q.timestamp = ts
      q.stock_symbol = stock_symbol
      q.bid_price = st['bid_price']
      q.quote_payload = st

      c = Company.find_or_create_by(stock_symbol: stock_symbol)
      c.save!

      q.company = c
      q.save!

      puts q.company.stock_symbol
    end

    return stocks.size
  end

end
