class Dummytter
  @@dummy = {:replies => [], :home_timeline => [], :direct_messages => [],
             :followers_ids => [], :friends_ids => []}
  def method_missing(name,*args)
    @@dummy[name] ||= []
    @@dummy[name].dup
  end

  def user(id)
    {:id=>id}
  end

  def self.dummy
    @@dummy
  end
end

$tinatra_spec_tweet_id = 0

def dummy_user(name)
  $tinatra_spec_tweet_id += 1
  {:profile_background_tile=>true,
   :favourites_count=>0, :description=>"hi",
   :profile_text_color=>"FFFFFF", :url=>"http://example.com/sorah",
   :geo_enabled=>false, :follow_request_sent=>false, :lang=>"ja", 
   :created_at=>"Sat Sep 01 15:00:00 +0000 2009", :profile_link_color=>"FFFFFF",
   :location=>"Tochigi", :verified=>false, :time_zone=>"Tokyo",
   :profile_sidebar_fill_color=>"FFFFFF",
   :profile_image_url=>"http://example.com/a.png",
   :following=>true, :listed_count=>0, :profile_use_background_image=>true,
   :profile_sidebar_border_color=>"FFFFFF",
   :followers_count=>1, :protected=>false,
   :screen_name=>name, :statuses_count=>1, :name=>name,
   :show_all_inline_media=>false,
   :profile_background_image_url=>"http://example.com/b.jpg",
   :friends_count=>1, :id=>$tinatra_spec_tweet_id, :contributors_enabled=>false, :notifications=>false,
   :utc_offset=>32400, :profile_background_color=>"FFFFFF"}
end

def dummy_tweet(t)
  $tinatra_spec_tweet_id += 1
  {:contributors=>nil, :in_reply_to_screen_name=>nil, :retweeted=>false,
   :truncated=>false, :created_at=>"Mon Sep 13 12:00:00 +0000 2010",
   :source=>"web",
   :retweet_count=>nil,:in_reply_to_user_id=>nil, :favorited=>false,
   :in_reply_to_status_id=>nil,
   :place=>nil, :coordinates=>nil,
   :user=>{:profile_background_tile=>true,
           :favourites_count=>0, :description=>"hi",
           :profile_text_color=>"FFFFFF", :url=>"http://example.com/sorah",
           :geo_enabled=>false, :follow_request_sent=>false, :lang=>"ja", 
           :created_at=>"Sat Sep 01 15:00:00 +0000 2009", :profile_link_color=>"FFFFFF",
           :location=>"Tochigi", :verified=>false, :time_zone=>"Tokyo",
           :profile_sidebar_fill_color=>"FFFFFF",
           :profile_image_url=>"http://example.com/a.png",
           :following=>true, :listed_count=>0, :profile_use_background_image=>true,
           :profile_sidebar_border_color=>"FFFFFF",
           :followers_count=>1, :protected=>false,
           :screen_name=>"foo", :statuses_count=>1, :name=>"foobar",
           :show_all_inline_media=>false,
           :profile_background_image_url=>"http://example.com/b.jpg",
           :friends_count=>1, :id=>1, :contributors_enabled=>false, :notifications=>false,
           :utc_offset=>32400, :profile_background_color=>"FFFFFF"},
   :geo=>nil, :id=>$tinatra_spec_tweet_id, :text=>t}
end

def dummy_reply(i,t)
  $tinatra_spec_tweet_id += 1
  {:contributors=>nil, :in_reply_to_screen_name=>"tinatra", :retweeted=>false,
   :truncated=>false, :created_at=>"Mon Sep 13 12:00:00 +0000 2010",
   :source=>"web",
   :retweet_count=>nil,:in_reply_to_user_id=>2, :favorited=>false,
   :in_reply_to_status_id=>i,
   :place=>nil, :coordinates=>nil,
   :user=>{:profile_background_tile=>true,
           :favourites_count=>0, :description=>"hi",
           :profile_text_color=>"FFFFFF", :url=>"http://example.com/sorah",
           :geo_enabled=>false, :follow_request_sent=>false, :lang=>"ja", 
           :created_at=>"Sat Sep 01 15:00:00 +0000 2009", :profile_link_color=>"FFFFFF",
           :location=>"Tochigi", :verified=>false, :time_zone=>"Tokyo",
           :profile_sidebar_fill_color=>"FFFFFF",
           :profile_image_url=>"http://example.com/a.png",
           :following=>true, :listed_count=>0, :profile_use_background_image=>true,
           :profile_sidebar_border_color=>"FFFFFF",
           :followers_count=>1, :protected=>false,
           :screen_name=>"foo", :statuses_count=>1, :name=>"foobar",
           :show_all_inline_media=>false,
           :profile_background_image_url=>"http://example.com/b.jpg",
           :friends_count=>1, :id=>1, :contributors_enabled=>false, :notifications=>false,
           :utc_offset=>32400, :profile_background_color=>"FFFFFF"},
   :geo=>nil, :id=>$tinatra_spec_tweet_id, :text=>t}

end

def dummy_direct(text)
  {:recipient_screen_name=>"tinatra", :recipient=>{},
   :created_at=>"Mon Sep 13 07:11:39 +0000 2010", :recipient_id=>2, :sender=>{},
   :sender_id=>1, :id=>$tinatra_spec_tweet_id, :sender_screen_name=>"foo", :text=>text}
end


