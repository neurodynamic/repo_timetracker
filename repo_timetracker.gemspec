# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'repo_timetracker/version'

Gem::Specification.new do |spec|
  spec.name          = "repo_timetracker"
  spec.version       = RepoTimetracker::VERSION
  spec.authors       = ["neurodynamic"]
  spec.email         = ["developer@neurodynamic.io"]
  spec.summary       = %q{A timetracker for git commits.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/neurodynamic/repo_timetracker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "filewatcher", "~> 0.4.0"
  spec.add_development_dependency "minitest", ">= 5.4.0"
  spec.add_development_dependency "timecop", "~> 0.7.1"
end
