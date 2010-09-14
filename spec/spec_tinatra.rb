$:.unshift "#{File.dirname(__FILE__)}/../lib"
$:.unshift "#{File.dirname(__FILE__)}"
require "tinatra"
require "helper_dummytter"

#Dummytter.dummy[:followers_ids] = 100.times.map{|i|i}

describe "Tinatra" do
  before do
    Dummytter.dummy[:verify_credentials] = {:user => {:id => 2, :screen_name => "tinatra"}}
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
    Tinatra.add_action(:foo, l)
    Tinatra.call_action(:foo)
    a.should == :twitra
  end

  it "adds and calls an action with args" do
    Tinatra.reset
    a = nil
    l = lambda{|*x| a = x}
    Tinatra.add_action(:foo, l)
    Tinatra.call_action(:foo, :bar)
    a.should == [:bar]
    Tinatra.call_action(:foo, :bar, :hoge)
    a.should == [:bar, :hoge]
  end

  describe "action" do
    it "timeline calls when detect new tweet in timeline" do
      r = nil
      tweet = dummy_tweet("hi")
      a = lambda{|t|r = t[:id]}
      Tinatra.add_action(:timeline, a)
      Tinatra.run
      Dummytter.dummy[:home_timeline] << tweet
      Tinatra.run
      r.should == tweet[:id]
    end

    it "mention calls when detect new tweet in mention" do
      r = nil
      target = dummy_tweet("hi")
      mention = dummy_reply(target[:id],"hi!!")
      Dummytter.dummy[:home_timeline] << target
      a = lambda{|t|r=t[:id]}
      Tinatra.add_action(:mention, a)
      Tinatra.run
      Dummytter.dummy[:replies] << mention
      Tinatra.run
      r.should == mention[:id]
    end

    it "direct_message calls when received new direct message" do
      dm = dummy_direct("hello")
      r = nil
      a = lambda{|d|r = d[:id]}
      Tinatra.add_action(:direct_message, a)
      Tinatra.run
      Dummytter.dummy[:direct_messages] << dm
      Tinatra.run
      r.should == dm[:id]
    end

    it "always calls always" do
      r = false
      a = lambda{r = true}
      Tinatra.add_action(:always, a)
      Tinatra.run
      r.should be_true
    end

    it "followed calls when followed by user" do
      r = nil
      a = lambda{|u|r = u[:id]}
      Tinatra.run
      Tinatra.add_action(:followed,a)
      Dummytter.dummy[:followers_ids] << 10000
      Tinatra.run
      r.should == 10000
    end

    it "removed calls when removed by user" do
      r = nil
      a = lambda{|u|r = u[:id]}
      Tinatra.run
      Tinatra.add_action(:removed,a)
      Dummytter.dummy[:followers_ids].delete 10000
      Tinatra.run
      r.should == 10000
    end
  end

  describe "config" do
    it "autofollow returns follow automatically" do
      pending
    end

    it "autoremove returns follow automatically" do
      pending
    end
  end
end
