class Word
  include Mongoid::Document

  field :name, type: String
  field :popularity, type: Integer

  has_and_belongs_to_many :tweets


  def self.calculate_popularity
    all_words = self.all

    all_words.each do |word|
      word.popularity = word.tweets.size
    end
  end

  def self.top(top)
    return self.all.sort(popularity: -1).limit(top)
  end
end
