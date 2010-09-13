require 'rubygems'
require 'oauth'
require 'rubytter'
require 'pstore'

class Tinatra
end

at_exit do
  Tinatra.start if $!.nil?
end
