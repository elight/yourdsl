# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yourdsl"

Gem::Specification.new do |s|
  s.name        = "yourdsl"
  s.version     = YourDSL::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Evan Light", "Ryan Allen"]
  s.email       = ["evan@tripledogdare.net", "ryan@ryanface.com"]
  s.homepage    = "http://rubygems.org/gems/yourdsl"
  s.summary     = %q{~1/2 of a compiler: a partial lexer and nested DSL language implementation}
  s.description = %q{Records an internal DSL for playback as an AST within Ruby}

  s.rubyforge_project = "yourdsl"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
