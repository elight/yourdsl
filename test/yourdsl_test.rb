require 'test/unit'
require 'yourdsl'

class YourDSLTest < Test::Unit::TestCase
  class Whatever
    extend YourDSL
    record_your_dsl

    setup :workers => 30, :connections => 1024
    http :access_log => :off do
      server :listen => 80 do
        location '/' do
          doc_root '/var/www/website'
        end
        location '~ .php$' do
          fcgi :port => 8877
          script_root '/var/www/website'
        end
      end
    end
    ohai
  end
  @@whatever = Whatever.output

  class MoarYourDSL
    extend YourDSL
    record_your_dsl

    setup
    setup do
      lol
      lol do
        hi
        hi
      end
    end
  end
  @@moar_yourdsl = MoarYourDSL.output

  class RetainBlocks
    extend YourDSL
    record_your_dsl :retain_blocks_for => [:Given, :When, :Then]

    Scenario "My first awesome scenario" do
      Given "teh shiznit" do
        #shiznit
      end

      When "I do something" do
        #komg.do_something
      end

      Then "this is pending"
    end
  end
  @@retain_blocks = RetainBlocks.output

  begin
    class OptInParsing
      extend YourDSL
      record_your_dsl :only => [:Foo]

      Foo "bar" do
        blech
      end
    end
  rescue
    @@opt_in_parsing_error = $!
  end

  begin
    class OptOutParsing
      extend YourDSL
      record_your_dsl :except => [:blech]

      Foo "bar" do
        blech
      end
    end
  rescue
    @@opt_out_parsing_error = $!
  end

  def test_yourdsl
    expected = YourDSL::Output.new(__FILE__, [
      YourDSL::Expression.new(:setup, {:workers=>30, :connections=>1024}, "9"),
      YourDSL::Expression.new(:http, {:access_log =>:off}, "10", nil,
        YourDSL::Scope.new.tap { |s1| s1.expressions = [
          YourDSL::Expression.new(:server, {:listen=>80}, "11", nil,
            YourDSL::Scope.new.tap { |s2| s2.expressions = [
              YourDSL::Expression.new(:location, '/', "12", nil,
                YourDSL::Scope.new.tap { |s3| s3.expressions = [
                  YourDSL::Expression.new(:doc_root, '/var/www/website', "13")
                ]}
              ),
              YourDSL::Expression.new(:location, '~ .php$', "15", nil,
                YourDSL::Scope.new.tap { |s4| s4.expressions = [
                  YourDSL::Expression.new(:fcgi, {:port => 8877}, "16"),
                  YourDSL::Expression.new(:script_root, '/var/www/website', "17")
                ]}
              )
            ]}
          )
        ]}
      ),
      YourDSL::Expression.new(:ohai, [], "21")
    ])
    assert_equal expected, @@whatever
  end

  def test_moar_yourdsl
    expected = YourDSL::Output.new(__FILE__, [
      YourDSL::Expression.new(:setup, [], "29"),
      YourDSL::Expression.new(:setup, [], "30", nil,
        YourDSL::Scope.new.tap { |s1| s1.expressions = [
          YourDSL::Expression.new(:lol, [], "31"),
          YourDSL::Expression.new(:lol, [], "32", nil,
            YourDSL::Scope.new.tap { |s2| s2.expressions = [
              YourDSL::Expression.new(:hi, [], "33"),
              YourDSL::Expression.new(:hi, [], "34")
            ]}
          )
        ]}
      )
    ])
    assert_equal expected, @@moar_yourdsl
  end

  def test_conditionally_preserving_procs
    ast = @@retain_blocks
    scenario = ast.expressions.first
    assert_equal :Scenario, scenario.symbol
    assert_equal "My first awesome scenario", scenario.args
    given = scenario.scope.expressions.first
    assert_equal :Given, given.symbol
    assert_equal "teh shiznit", given.args
    assert_instance_of Proc, given.proc
    assert_nil given.scope
  end

  def test_opt_in_parsing
    assert_instance_of NoMethodError, @@opt_in_parsing_error
    assert_match "blech", @@opt_in_parsing_error.message
  end

  def test_opt_out_parsing
    begin
      flunk if @@opt_out_parsing_fail
    rescue
      assert_instance_of NoMethodError, @@opt_out_parsing_error
      assert_match "blech", @@opt_out_parsing_error.message
    end
  end
end
