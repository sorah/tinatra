$:.unshift "#{File.dirname(__FILE__)}/../lib"
require "tinatra"

mention do |m|
  puts "mention #{m[:user][:screen_name]}: #{m[:text]}"
end

timeline do |m|
  puts "timeline #{m[:user][:screen_name]}: #{m[:text]}"
end

direct_message do |m|
  puts "dm #{m[:user][:screen_name]}: #{m[:text]}"
end

always do
  puts "always"
end
