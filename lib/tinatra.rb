require 'rubygems'
require 'oauth'
require 'rubytter'
require 'pstore'
require 'singleton'

class Hash
  def transaction
    yield self
  end
end

class Tinatra
  include Singleton

  def initialize
    @config = {:rubytter => OAuthRubytter}
    @actions = {}
    @db = nil
    @t = nil
  end

  def reset
    initialize
  end

  def set(a,b)
    @config[a]=b
  end

  def add_action(event, block)
    @actions[event] ||= []
    @actions[event] << block
  end

  def call_action(event, *args)
    @actions[event] ||= []
    @actions[event].each do |a|
      a.call(*args)
    end
  end

  def run
    init_db
    init_twit

    call_action(:always)

    [[:mention, :replies], [:timeline, :home_timeline],
     [:direct_message, :direct_messages]].each do |act|
      if @actions[act[0]]
        r = @t.__send__(act[1])
        @db.transaction do |d|
          (r - d[act[0]]).each do |new|
            call_action(act[0],new)
          end
        end
      end
    end
    
    @db.transaction do |d|
      if @actions[:followed]||@actions[:removed]
        f = @t.followers_ids(d[:self][:id])
        [[:followed,(f-d[:follower])],
         [:removed,(d[:follower]-f)]].each do |x|
          if @actions[x[0]]
            x[1].each do |n|
              call_action(x[0],@t.user(n))
            end
          end
        end
        d[:follower] = f
      end
    end
  end

  def self.method_missing(name, *args)
    Tinatra.instance.__send__(name, *args)
  end

  attr_reader :config

  module Helpers
  end
  include Helpers

  private

  def init_twit
    return @t if @t
    init_db
    @db.transaction do |d|
      if !@config[:spec] && !d[:token].nil? \
                         && d[:token].empty?
        # TODO: Need authentication..
      end
      access_token = nil # NOTE: Fix this
      @t = @config[:rubytter].new(access_token)
      d[:self] = @t.verify_credentials
    end
  end

  def init_db
    return @db if @db
    if @config[:db] == :memory
      @db = {}
    else
      @db = PStore.new(@config[:db])
    end
    make_db
  end

  def make_db
    @db.transaction do |d|
      [:token,:mention,:direct_message,
       :timeline,:follower,:following].each{|k|d[k]=[]}
    end
  end


end

module Kernel
  def set(*args)
    Tinatra.instance.set(*args)
  end
  def db(path)
    Tinatra.instance.set(:db,path)
  end
end

at_exit do
  Tinatra.start if $!.nil?
end
