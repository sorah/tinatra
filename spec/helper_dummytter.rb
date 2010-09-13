class Dummytter
  def initialize(*args)
    @dummy = {:replies => [], :home_timeline => [], :direct_messages => [],
              :followers_ids => [], :friends_ids => []}
  end

  def method_missing(name,*args)
    @dummy[name] ||= []
    @dummy[name]
  end
  attr_accessor :dummy
end
