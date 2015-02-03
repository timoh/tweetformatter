class Fetcher

  def self.fetch

    require 'net/http'
    json = Net::HTTP.get('tweetextractor.herokuapp.com', '/')

    require 'json'
    tweets = JSON.parse(json)

    return tweets
  end

  def self.persist(tweets)
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

end
