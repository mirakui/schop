# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "schop/version"

Gem::Specification.new do |s|
  s.name        = "schop"
  s.version     = Schop::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["mirakui"]
  s.email       = ["mirakui@tsuyabu.in"]
  s.homepage    = "http://github.com/mirakui/schop"
  s.summary     = %q{A ruby cli wrapper to make ssh tunneling a no brainer}
  s.description = %q{A ruby cli wrapper to make ssh tunneling a no brainer}

  s.rubyforge_project = "schop"
  s.add_dependency "thor", "0.14.3"
  s.add_dependency "highline", "~> 1.6"
  s.add_dependency "daemons", "~> 1.1.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
