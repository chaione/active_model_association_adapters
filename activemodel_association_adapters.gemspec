# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active_model_association_adapters/version"

Gem::Specification.new do |s|
  s.name        = "activemodel_association_adapters"
  s.version     = ActiveModelAssociationAdapters::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Scott Burton"]
  s.email       = ["scott.burton@chaione.com"]
  s.homepage    = "http://www.chaione.com"
  s.summary     = %q{Simple association adapters for polyglot applications}
  s.description = %q{Simple association adapters for ActiveModel-compliant models used in polyglot applications.}

  s.rubyforge_project = "mongoid_activerecord_adapter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
