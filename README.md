# YourDSL

A partial internal DSL compiler.

Lexing/Parsing responsibilities are handled by a combination of the Ruby interpreter itself (Ruby already lexes and parses itself) and a recorder to capture undefined Ruby methods, via *method_missing*, as an Abstract Syntax Tree (AST).

You supply the code generator.

## Assumptions.

* People love libraries with DSLs like Sinatra and ActiveRecord and Babushka and AASM and (name your favourite Ruby library).
* What they love about these is the small amount of Ruby syntax required to get a whole lot done.
* They love that they can contextualise their definitions (that make the libraries do things) with natural Ruby syntax such as blocks.
* To enable these kinds of libraries the use of so-called 'meta-programming' constructs are required (instance_eval, instance_exec).
* Clever but inexperienced Ruby programmers often make very useful libraries with wonderful APIs but horrible internals

## Goals.

* Decouple the language definition of an internal DSL from its implementation
* Allow library authors to dream up APIs and implement them without entering Ruby metaprogramming hell (it is a real place).

## Example
    class Feature < Test::Unit::TestCase
      # Configuring lispy to geenrate an AST for our language

      PROC_KEYWORDS = [:Given, :When, :Then, :And]
      KEYWORDS = [:Scenario, :Tag] + PROC_KEYWORDS

      extend YourDSL
      record_your_dsl :only => KEYWORDS, :retain_blocks_for => PROC_KEYWORDS

      # Using our language
      Scenario "this gets lispyified" do
        Given "something" do
        end

        Then "test something exists" do
          fail "ohai"
        end
      end
    end

    # Barfing out the AST for the above
    require 'rubygems'
    require 'awesome_print'
    ap Feature.output

    # Example 'interpreter' for the AST generated above
    # Executes the block on the Given and Then from above sequentially
    # Spike on how an acceptance testing DSL could work
    Feature.class_eval do
      def test_something
        scenario = Feature.output.expressions.first
        steps = scenario.scope.expressions
        instance_eval &steps[0].proc
        instance_eval &steps[1].proc
      end
    end

     OUTPUTS:
     ➜  example git:(no_more_last_last_last) ✗ ruby feature.rb
     {
                :file => "feature.rb",
         :expressions => [
             [0] {
                 :symbol => :Scenario,
                   :args => "this gets lispyified",
                 :lineno => "14",
                   :proc => nil,
                  :scope => {
                     :expressions => [
                         [0] {
                             :symbol => :Given,
                               :args => "something",
                             :lineno => "15",
                               :proc => #<Proc:0x000001010e9140@feature.rb:15>,
                              :scope => nil
                         },
                         [1] {
                             :symbol => :Then,
                               :args => "test something exists",
                             :lineno => "18",
                               :proc => #<Proc:0x000001010e8ec0@feature.rb:18>,
                              :scope => nil
                         }
                     ]
                 }
             }
         ]
     }
     Loaded suite feature
     Started
     E
     Finished in 0.006305 seconds.

       1) Error:
     test_something(Feature):
     RuntimeError: ohai
         feature.rb:19:in `block (2 levels) in <class:Feature>'
         feature.rb:34:in `instance_eval'
         feature.rb:34:in `test_something'

     1 tests, 0 assertions, 0 failures, 1 errors, 0 skips

## Credits

* Lispy concept and original impl by Ryan Allen (http://github.com/ryan-allen/lispy)
* Rewritten and extended by Evan Light (http://github.com/elight/yourdsl)

## License.

Released under the MIT license (see MIT-LICENSE).
