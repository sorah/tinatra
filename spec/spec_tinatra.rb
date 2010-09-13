$:.unshift "#{File.dirname(__FILE__)}/../lib"
$:.unshift "#{File.dirname(__FILE__)}"
require "tinatra"
require "helper_dummytter"

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

describe "Tinatra" do
  before do
    Tinatra.set :spec, true
    Tinatra.set :db, :memory
    Tinatra.set :rubytter, Dummytter
  end
  it "sets config by Kernel#set" do
    Kernel.set :foo, :bar
    Tinatra.config[:foo].should == :bar
  end

  it "adds and calls an action" do
    Tinatra.reset
    a = nil
    l = lambda{ a = :twitra}
    Tinatra.add_action(:foo, &l)
    Tinatra.call_action(:foo)
    a.should == :twitra
  end

  it "adds and calls an action with args" do
    Tinatra.reset
    a = nil
    l = lambda{|*x| a = x}
    Tinatra.add_action(:foo, &l)
    Tinatra.call_action(:foo, :bar)
    a.should == [:bar]
    Tinatra.call_action(:foo, :bar, :hoge)
    a.should == [:bar, :hoge]
  end

  describe "action" do
    it "timeline calls when detect new tweet in timeline" do
      r = nil
      a = lambda{|t|r = t[:text]}
      Tinatra.add_action(:timeline, &a)
      Tinatra.run
      Dummytter.dummy[:home_timeline] << dummy_tweet("hi")
      Tinatra.run
      r.should == "hi"
    end

    it "mention calls when detect new tweet in mention" do
      r = []
      target = dummy_tweet("hi")
      mention = dummy_reply(target[:id],"hi!!")
      Dummytter.dummy.timeline << target
      a = lambda{|t,r|r[0]=t[:id]; r[1]=r[:id]}
      Tinatra.add_action(:mention, &a)
      Tinatra.run
      Dummytter.dummy[:replies] << mention
      Tinatra.run
      r[0].should == mention[:id]
      r[1].should == target[:id]
    end

    it "direct_message calls when received new direct message" do
      dm = dummy_direct("hello")
      r = nil
      a = lambda{|d|r = d[:id]}
      Tinatra.add_action(:direct_message, &a)
      Tinatra.run
      Dummytter.dummy[:direct_messages] << dm
      Tinatra.run
      r.should == dm[:id]
    end

    it "always calls always" do
      r = false
      a = lambda{r = true}
      Tinatra.add_action(:always, &a)
      Tinatra.run
      r.should be_true
    end

    it "followed calls when followed by user" do
      r = nil
      a = lambda{|u|r = u[:id]}
      Tinatra.run
      Dummytter.dummy[:followers_ids] << 5
      Tinatra.run
      a.should == 5
    end

    it "removed calls when removed by user" do
      r = nil
      a = lambda{|u|r = u[:id]}
      Tinatra.run
      Dummytter.dummy[:followers_ids].delete 5
      Tinatra.run
      a.should == 5
    end
  end

  describe "config" do
    it "autofollow returns follow automatically"

    it "autoremove returns follow automatically"
  end
end
