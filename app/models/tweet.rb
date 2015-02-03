class Tweet
  include Mongoid::Document

  field :tweet_id, type: String
  field :text, type: String
  field :screen_name, type: String
  field :datetime, type: DateTime
  field :tweet_payload, type: Hash

  has_and_belongs_to_many :words

  validates_uniqueness_of :tweet_id
  validates_presence_of :tweet_payload, :tweet_id, :text, :screen_name, :datetime

   def self.group_by(field, format = 'day')
    key_op = [['year', '$year'], ['month', '$month'], ['day', '$dayOfMonth']]
    key_op = key_op.take(1 + key_op.find_index { |key, op| format == key })
    project_date_fields = Hash[*key_op.collect { |key, op| [key, {op => "$#{field}"}] }.flatten]
    group_id_fields = Hash[*key_op.collect { |key, op| [key, "$#{key}"] }.flatten]
    pipeline = [
        {"$project" => {"name" => 1, field => 1}.merge(project_date_fields)},
        {"$group" => {"_id" => group_id_fields, "count" => {"$sum" => 1}}},
        {"$sort" => {"count" => -1}}
    ]
    collection.aggregate(pipeline)
  end

  def self.produce_csv
    daily_counts = Tweet.produce_daily_counts

    file_path = Dir.pwd + '/public/output.csv'

    CSV.open(filepath, "wb") do |csv|
      # csv << ["row", "of", "CSV", "data"]
      # csv << ["another", "row"]
      # ...

      # daily_counts.each {|key, value|  }
      # end
    end

  end

  def self.produce_daily_counts(lower_level = 2) # using lower level of 2 as default

    daily_counts = Array.new

    start_date = (DateTime.now.to_date-10)
    end_date = (DateTime.now.to_date+1)

    current_date = start_date

    while current_date <= end_date do

      tweets = Tweet.where({:datetime.gte => (current_date).strftime("%Y-%m-%d"), :datetime.lte => (current_date+1).strftime("%Y-%m-%d")})

      dates = Set.new

      tweets.each do |tw|
        dates << tw.datetime.to_date
      end

      #puts "Dates in this range (#{current_date.to_s(:short)}) are #{dates.to_a.to_s}"

      if tweets.size > 0 # tweets for this date found
        wc = Tweet.inmem_word_count(tweets, lower_level) 
        #puts "Word count for #{current_date.to_s(:short)} is #{wc}."

        wc.each do |c|
          c.each do |key, value|
            dc = DailyCount.new 

              # field :date, type: Date
              # field :company_symbol, type: String
              # field :count, type: Integer

            dc.date = current_date.to_date
            dc.company_symbol = key
            dc.count = value.to_i
            dc.save!
          end
        end

        #daily_counts << {current_date => wc}
      else # tweets for this date not found
        #daily_counts << {current_date => {}}
      end

      current_date = (current_date+1)
    end

    return DailyCount.all.size
  end


  def self.inmem_word_count(tweet_array, lower_level) # lower_level is the count that a word needs to have to be included
    raise 'Tweet array empty!' if tweet_array.length <= 0
    all_tweets = tweet_array
    words = []

    all_tweets.each do |tweet|
      words = words.concat(tweet.text.gsub(/[^-a-zA-Z$#]/, ' ').split)
    end

    puts "Total amount of words before stopword removal: #{words.size}"

    stopwords = ["a","about","above","after","again","against","all","am","an","and","any","are","aren't","as","at","be","because","been","before","being","below","between","both","but","by","can't","cannot","could","couldn't","did","didn't","do","does","doesn't","doing","don't","down","during","each","few","for","from","further","had","hadn't","has","hasn't","have","haven't","having","he","he'd","he'll","he's","her","here","here's","hers","herself","him","himself","his","how","how's","i","i'd","i'll","i'm","i've","if","in","into","is","isn't","it","it's","its","itself","let's","me","more","most","mustn't","my","myself","no","nor","not","of","off","on","once","only","or","other","ought","our","ours","ourselves","out","over","own","same","shan't","she","she'd","she'll","she's","should","shouldn't","so","some","such","than","that","that's","the","their","theirs","them","themselves","then","there","there's","these","they","they'd","they'll","they're","they've","this","those","through","to","too","under","until","up","very","was","wasn't","we","we'd","we'll","we're","we've","were","weren't","what","what's","when","when's","where","where's","which","while","who","who's","whom","why","why's","with","won't","would","wouldn't","you","you'd","you'll","you're","you've","your","yours","yourself","yourselves","a's","accordingly","again","allows","also","amongst","anybody","anyways","appropriate","aside","available","because","before","below","between","by","can't","certain","com","consider","corresponding","definitely","different","don't","each","else","et","everybody","exactly","fifth","follows","four","gets","goes","greetings","has","he","her","herein","him","how","i'm","immediate","indicate","instead","it","itself","know","later","lest","likely","ltd","me","more","must","nd","needs","next","none","nothing","of","okay","ones","others","ourselves","own","placed","probably","rather","regarding","right","saying","seeing","seen","serious","she","so","something","soon","still","t's","th","that","theirs","there","therein","they'd","third","though","thus","toward","try","under","unto","used","value","vs","way","we've","weren't","whence","whereas","whether","who's","why","within","wouldn't","you'll","yourself","able","across","against","almost","although","an","anyhow","anywhere","are","ask","away","become","beforehand","beside","beyond","c'mon","cannot","certainly","come","considering","could","described","do","done","edu","elsewhere","etc","everyone","example","first","for","from","getting","going","had","hasn't","he's","here","hereupon","himself","howbeit","i've","in","indicated","into","it'd","just","known","latter","let","little","mainly","mean","moreover","my","near","neither","nine","noone","novel","off","old","only","otherwise","out","particular","please","provides","rd","regardless","said","says","seem","self","seriously","should","some","sometime","sorry","sub","take","than","that's","them","there's","theres","they'll","this","three","to","towards","trying","unfortunately","up","useful","various","want","we","welcome","what","whenever","whereby","which","whoever","will","without","yes","you're","yourselves","about","actually","ain't","alone","always","and","anyone","apart","aren't","asking","awfully","becomes","behind","besides","both","c's","cant","changes","comes","contain","couldn't","despite","does","down","eg","enough","even","everything","except","five","former","further","given","gone","hadn't","have","hello","here's","hers","his","however","ie","inasmuch","indicates","inward","it'll","keep","knows","latterly","let's","look","many","meanwhile","most","myself","nearly","never","no","nor","now","often","on","onto","ought","outside","particularly","plus","que","re","regards","same","second","seemed","selves","seven","shouldn't","somebody","sometimes","specified","such","taken","thank","thats","themselves","thereafter","thereupon","they're","thorough","through","together","tried","twice","unless","upon","uses","very","wants","we'd","well","what's","where","wherein","while","whole","willing","won't","yet","you've","zero","above","after","all","along","am","another","anything","appear","around","associated","be","becoming","being","best","brief","came","cause","clearly","concerning","containing","course","did","doesn't","downwards","eight","entirely","ever","everywhere","far","followed","formerly","furthermore","gives","got","happens","haven't","help","hereafter","herself","hither","i'd","if","inc","inner","is","it's","keeps","last","least","like","looking","may","merely","mostly","name","necessary","nevertheless","nobody","normally","nowhere","oh","once","or","our","over","per","possible","quite","really","relatively","saw","secondly","seeming","sensible","several","since","somehow","somewhat","specify","sup","tell","thanks","the","then","thereby","these","they've","thoroughly","throughout","too","tries","two","unlikely","us","using","via","was","we'll","went","whatever","where's","whereupon","whither","whom","wish","wonder","you","your","according","afterwards","allow","already","among","any","anyway","appreciate","as","at","became","been","believe","better","but","can","causes","co","consequently","contains","currently","didn't","doing","during","either","especially","every","ex","few","following","forth","get","go","gotten","hardly","having","hence","hereby","hi","hopefully","i'll","ignored","indeed","insofar","isn't","its","kept","lately","less","liked","looks","maybe","might","much","namely","need","new","non","not","obviously","ok","one","other","ours","overall","perhaps","presumably","qv","reasonably","respectively","say","see","seems","sent","shall","six","someone","somewhere","specifying","sure","tends","thanx","their","thence","therefore","they","think","those","thru","took","truly","un","until","use","usually","viz","wasn't","we're","were","when","whereafter","wherever","who","whose","with","would","you'd","yours","IÊ","aÊ","aboutÊ","anÊ","areÊ","asÊ","atÊ","beÊ","byÊ","comÊ","forÊ","from","how","inÊ","isÊ","itÊ","ofÊ","onÊ","orÊ","that","theÊ","this","toÊ","wasÊ","whatÊ","when","where","whoÊ","willÊ","with","the","www","a","able","about","above","abst","accordance","according","accordingly","across","act","actually","added","adj","affected","affecting","affects","after","afterwards","again","against","ah","all","almost","alone","along","already","also","although","always","am","among","amongst","an","and","announce","another","any","anybody","anyhow","anymore","anyone","anything","anyway","anyways","anywhere","apparently","approximately","are","aren","arent","arise","around","as","aside","ask","asking","at","auth","available","away","awfully","b","back","be","became","because","become","becomes","becoming","been","before","beforehand","begin","beginning","beginnings","begins","behind","being","believe","below","beside","besides","between","beyond","biol","both","brief","briefly","but","by","c","ca","came","can","cannot","can't","cause","causes","certain","certainly","co","com","come","comes","contain","containing","contains","could","couldnt","d","date","did","didn't","different","do","does","doesn't","doing","done","don't","down","downwards","due","during","e","each","ed","edu","effect","eg","eight","eighty","either","else","elsewhere","end","ending","enough","especially","et","et-al","etc","even","ever","every","everybody","everyone","everything","everywhere","ex","except","f","far","few","ff","fifth","first","five","fix","followed","following","follows","for","former","formerly","forth","found","four","from","further","furthermore","g","gave","get","gets","getting","give","given","gives","giving","go","goes","gone","got","gotten","h","had","happens","hardly","has","hasn't","have","haven't","having","he","hed","hence","her","here","hereafter","hereby","herein","heres","hereupon","hers","herself","hes","hi","hid","him","himself","his","hither","home","how","howbeit","however","hundred","i","id","ie","if","i'll","im","immediate","immediately","importance","important","in","inc","indeed","index","information","instead","into","invention","inward","is","isn't","it","itd","it'll","its","itself","i've","j","just","k","keep","keeps","kept","kg","km","know","known","knows","l","largely","last","lately","later","latter","latterly","least","less","lest","let","lets","like","liked","likely","line","little","'ll","look","looking","looks","ltd","m","made","mainly","make","makes","many","may","maybe","me","mean","means","meantime","meanwhile","merely","mg","might","million","miss","ml","more","moreover","most","mostly","mr","mrs","much","mug","must","my","myself","n","na","name","namely","nay","nd","near","nearly","necessarily","necessary","need","needs","neither","never","nevertheless","new","next","nine","ninety","no","nobody","non","none","nonetheless","noone","nor","normally","nos","not","noted","nothing","now","nowhere","o","obtain","obtained","obviously","of","off","often","oh","ok","okay","old","omitted","on","once","one","ones","only","onto","or","ord","other","others","otherwise","ought","our","ours","ourselves","out","outside","over","overall","owing","own","p","page","pages","part","particular","particularly","past","per","perhaps","placed","please","plus","poorly","possible","possibly","potentially","pp","predominantly","present","previously","primarily","probably","promptly","proud","provides","put","q","que","quickly","quite","qv","r","ran","rather","rd","re","readily","really","recent","recently","ref","refs","regarding","regardless","regards","related","relatively","research","respectively","resulted","resulting","results","right","run","s","said","same","saw","say","saying","says","sec","section","see","seeing","seem","seemed","seeming","seems","seen","self","selves","sent","seven","several","shall","she","shed","she'll","shes","should","shouldn't","show","showed","shown","showns","shows","significant","significantly","similar","similarly","since","six","slightly","so","some","somebody","somehow","someone","somethan","something","sometime","sometimes","somewhat","somewhere","soon","sorry","specifically","specified","specify","specifying","still","stop","strongly","sub","substantially","successfully","such","sufficiently","suggest","sup","sure"]
    words = words - stopwords

    puts "Amount of words after stopword removal: #{words.size}"

    counts = Hash.new(0)
    words.each {|word| counts[word] += 1}

    filtered_counts = Array.new

    counts.each {|key, value| if key.to_s.include?("$") && value > lower_level && key.length > 1 then filtered_counts << {key => value} end }

    filtered_counts
  end


  def word_count
    txt = self.text
    raise 'Text is too short!' if txt.length <= 0

    word_array = txt.gsub(/[^-a-zA-Z]/, ' ').split

    # puts word_array.to_s

    word_array.each do |word|
      w = Word.find_or_initialize_by(name: word)
      w.tweets << self
      w.save(validate: false)
    end

  end

  def self.mass_word_count
    all_tweets = self.all

    puts "Starting to iterate over #{all_tweets.size} tweets"

    counter = 0

    all_tweets.each do |tw|
      counter = counter + 1
      tw.word_count

      if counter % 50 == 0
        puts "#{Time.now.to_s}: Reached #{counter} tweets, which is #{(counter.to_f / all_tweets.size.to_f).round(2).to_s} percent."
      end
    end

    return all_tweets.size
  end

end
