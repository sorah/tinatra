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

  def method_missing(name, *args)
    return self.instance.__send__(name, *args) if self.instance.respond_to?(name)
    super name, *args
  end
end

module Kernel
  def set(*args)
    Tinatra.set(*args)
  end
end

at_exit do
  Tinatra.start if $!.nil?
end
