#!/usr/bin/env ruby
require 'bundler/setup'
require 'yajl'
require 'open-uri'

INFINITY = 1.0/0

def debug(msg)
  puts msg if ENV["DEBUG"]
end

def latest_stored_tweet_id
  max = 0
  tweet = nil

  if $all_tweets
    $all_tweets.each do |value|
      id = value['id'].to_i
      
      if id > max
        max = id
        tweet = value
      end
    end

    puts "Starting from Tweet #{max}"
  end

  tweet && tweet['id']
end

def get_minimum_tweet_id(tweets)
  min = INFINITY

  if tweets
    tweets.each do |value|
      id = value['id'].to_i

      min = id if id < min
    end
  end

  min
end

def load_tweets()
  last_id = latest_stored_tweet_id
  url = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{$username}&trim_user=1&count=200&include_rts=1&include_entities=1"
  url << "&since_id=#{last_id}" if last_id
  tweets = []
  result = nil
  page = 1
  min = INFINITY
  until page > 1 && result.empty?
    debug "Fetching page #{page}..."
    
    if min < INFINITY
      final_url = "#{url}&max_id=#{min}"
    else
      final_url = url
    end

    open(final_url) do |f|
      page  += 1
      result = Yajl::Parser.parse(f.read)
      debug "got #{result.length} tweets"
      min = get_minimum_tweet_id(result) - 1
      tweets = tweets | result if !result.empty?
    end
  end
  tweets
end

def store_tweets()
  if !File.exists?($username + ".json")
    File.new($username + ".json", 'w')
  end
  file = File.new($username + ".json", 'r')
  $all_tweets = Yajl::Parser.parse(file)

  tweets = load_tweets()
  puts "Importing #{tweets.size} new tweets..."
  tweets.reverse!

  if $all_tweets
    store = $all_tweets | tweets 
  else
    store = tweets
  end
  
  puts "Saving #{store.size} tweets..."
  file = File.new(ARGV[0] + ".json", 'w')
  Yajl::Encoder.encode(store, file)
end

$username = ARGV[0]
store_tweets() if __FILE__ == $0
