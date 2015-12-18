$:.push File.expand_path("../lib", __FILE__)
require "dither/version"

Gem::Specification.new do |s|
  s.name        = "dither"
  s.version     = Dither::VERSION
  s.licenses    = ['MIT']
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Gowan"]
  s.email       = ["gowanjason@gmail.com"]
  s.homepage    = "https://github.com/jesg/dither"
  s.summary     = %q{Collection of test generation strategies}
  s.description = %q{Efficient test generation strategies}

  s.rubyforge_project = "dither"

  s.add_development_dependency "rspec", "~> 3.2"
  s.add_development_dependency "rake", "~> 0.9.2"
  s.add_development_dependency "rake-compiler"
  s.add_development_dependency "coveralls"

  files         = `git ls-files`.split("\n")

  if RUBY_PLATFORM =~ /java/
    s.platform = "java"
    files << "lib/dither.jar"
	else
		s.add_dependency "ffi", "~> 1.0"
		s.extensions = 'ext/dither/extconf.rb'
  end
  s.files = files

  s.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
