require File.dirname(__FILE__) + '/../lib/punchclock'
require 'test/unit'
require 'shoulda'

require 'rr'

class Test::Unit::TestCase
  include RR::Adapters::RRMethods
end
