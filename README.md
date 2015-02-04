# TweetFormatter rails app

## Important models

### Fetcher
* (tweets[]) fetch_tweets
* (stocks[]) fetch_stocks
* (boolean) persist_tweets(tweets[])
* (boolean) persist_stocks(stocks[])

Purpose of fetcher is to fetch Tweets and Stocks with net/http and to persist them into MongoDB for further processing.

### Quote
The Quote model presists quotes for stocks that are being fetched by the Fetcher model.

* (all_companies[]) all_companies
* TODO: (rows[]) generate_rows
* TODO: The Quote model should also be able to produce aggregates and a CSV output

The "all_companies" method returns an array of strings of each of the companies' stock symbols that have quotes associated with them. Used for creating the header rows for the CSV and for acquiring corresponding data.

TODO: The "generate_rows" method should return an array of string 

### Tweet
MongoDB model for persisting Tweets

* DEPRECATED group_by(field) 
* produce_daily_counts(lower_level)
* inmem_word_count(tweet_array[], lower_level)
* DEPRECATED word_count
* DEPRECATED mass_word_count

The "produce_daily_counts" method is used to iterate over all tweets within a certain date range and then persist these daily counts into the DailyCount model, for further processing into a CSV.

"word_count" and "mass_word_count" are deprecated, the algorithm iterating over MongoDB was just too slow.

"group_by" method was used to experiment with MongoDB's aggregation framework but didn't yield the result we were looking for.

### DailyCount
* company_date
* all_counts_as_csv

The "company_date" method is used to create a unique key from the symbol and date to ensure that counts are done only once per company and date

The "all_counts_as_csv" saves a .csv file into 'public/output.csv' from the DailyCount model persisted in MongoDB

### Company
Helper model for keeping Quotes organized. Might be superfluous, might be we'll make do with just the Quote model.

### DEPRECATED Word
The Word model was supposed to be used for word count purposes but MongoDB proved to be too slow for this purpose.

# Getting the MongoLab URI
* heroku config | grep MONGOLAB_URI
