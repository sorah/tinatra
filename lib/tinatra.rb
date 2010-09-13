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
    @config = {}
  end

  def set(a,b)
    @config[a]=b
  end

  def self.method_missing(name, *args)
    Tinatra.instance.__send__(name, *args)
  end
  attr_reader :config

  module Helpers
  end
  include Helpers
end

module Kernel
  def set(*args)
    Tinatra.instance.set(*args)
  end
end

at_exit do
  Tinatra.start if $!.nil?
end
