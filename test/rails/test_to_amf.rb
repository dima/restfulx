$:.unshift(File.dirname(__FILE__))

require 'helpers/unit_test_helper'
require 'ruby-prof'
require 'perftools'

class ToAMFTest < ActiveRecord::TestCase
  fixtures :users
  
  def test_to_amf_sanity
    assert_nothing_raised { users(:user_1).to_amf }
  end
  
  def test_ruby_profile_all_to_amf
    ruby_profile { users.to_amf }
  end
  
  def test_perftools_all_to_amf
    PerfTools::CpuProfiler.start("/tmp/to_amf") { users.to_amf }
  end
  
  private
  def ruby_profile
    RubyProf.start
    yield
    result = RubyProf.stop
    printer = RubyProf::GraphPrinter.new(result)
    printer.print(STDOUT, 0)
  end
end