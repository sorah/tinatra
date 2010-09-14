require 'rubygems'
require 'oauth'
require 'rubytter'
require 'pstore'
require 'singleton'
require 'highline'

class Hash
  def transaction
    yield self
  end
end

#oauth-patch.rb http://d.hatena.ne.jp/shibason/20090802/1249204953
if RUBY_VERSION >= '1.9.0'
  module OAuth
    module Helper
      def escape(value)
        begin
          URI::escape(value.to_s, OAuth::RESERVED_CHARACTERS)
        rescue ArgumentError
          URI::escape(
            value.to_s.force_encoding(Encoding::UTF_8),
            OAuth::RESERVED_CHARACTERS
          )
        end
      end
    end
  end

  module HMAC
    class Base
      def set_key(key)
        key = @algorithm.digest(key) if key.size > @block_size
        key_xor_ipad = Array.new(@block_size, 0x36)
        key_xor_opad = Array.new(@block_size, 0x5c)
        key.bytes.each_with_index do |value, index|
          key_xor_ipad[index] ^= value
          key_xor_opad[index] ^= value
        end
        @key_xor_ipad = key_xor_ipad.pack('c*')
        @key_xor_opad = key_xor_opad.pack('c*')
        @md = @algorithm.new
        @initialized = true
      end
    end
  end
end



class Tinatra
  API_BASE = 'http://api.twitter.com/'
  include Singleton

  def initialize
    @config = {:rubytter => OAuthRubytter}
    @actions = {}
    @db = nil
    @t = nil
  end

  def parse_option
    init = false
    help = false
    ARGV.each do |a|
      case a
      when "--init"
        init = true
        help = false
      when /--db=(.+)/
        set :db, $1
      when "--help"
        help = true
        init = false
      end
    end

    authorize if init
    if help
      puts <<-EOH
Usage: #{File.basename($0)} [--db=DATABASE] [--init|--help]

  --db   -- set a path to database file.
  --init -- authorize an account
  --help -- show this message
      EOH
      exit
    end
  end

  def authorize
    puts "------------ AUTHORIZING ------------"
    init_db
    @db.transaction do |d|
      if d[:consumer]
        puts "You're already setted consumer key/secret."
        cons_again = HighLine.new.agree("Input consumer key/secret again? ")
      else
        cons_again = true
      end

      if cons_again
        cons = []
        cons << HighLine.new.ask("Input your consumer key: ")
        cons << HighLine.new.ask("Input your consumer secret: ")
        d[:consumer] = OAuth::Consumer.new(cons[0],cons[1], :site => API_BASE)
      end

      puts

      request_token = d[:consumer].get_request_token
      puts "Access This URL and press 'Allow' in account for tinatra => #{request_token.authorize_url}"
      pin = HighLine.new.ask('Input key shown by twitter: ')
      access_token = request_token.get_access_token(
        :oauth_verifier => pin
      )
      d[:token] = access_token#[access_token.token.dup,access_token.secret.dup]

      @t = @config[:rubytter].new(access_token)
      d[:self] = eval(@t.verify_credentials.inspect)

      puts
      puts "Authorizing is done."
    end
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
      a.yield(*args)
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
          d[act[0]] = eval(r.inspect)
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
        d[:follower] = eval(f.inspect)
      end
    end
  end

  def api
    init_twit unless @t
    @t
  end

  [:mention,:timeline,:direct_message,:always,:followed,:removed].each do |act|
    eval "def #{act}(&block); add_action(:#{act},block); end"
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
      if d[:consumer].nil? || d[:token].nil?
        abort "Run #{File.basename($0)} --init first." unless @config[:spec]
      end
      access_token = nil
      if @config[:spec]
        d[:self] = @config[:rubytter].new.verify_credentials
      end
      @t = @config[:rubytter].new(d[:token])
    end
  end

  def init_db
    return @db if @db
    if @config[:db] == :memory
      @db = {}
    else
      unless @config[:db]
        abort "You must set a path to db file using --db= or db method."
      end
      @db = PStore.new(@config[:db])
    end
    make_db
  end

  def make_db
    @db.transaction do |d|
      unless d[:initialized]
        d[:initialized] = true
        [:mention,:direct_message,
         :timeline,:follower,:following].each{|k|d[k]=[]}
      end
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
  [:mention,:timeline,:direct_message,:always,:followed,:removed].each do |act|
    eval "def #{act}(&block); Tinatra.instance.#{act}(&block); end"
  end

  def api
    Tinatra.instance.api
  end
end

at_exit do
 if $!.nil? && !Tinatra.config[:spec]
   Tinatra.parse_option
   Tinatra.run
 end
end
