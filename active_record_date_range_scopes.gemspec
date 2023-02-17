lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_record/date_range_scopes/version"

Gem::Specification.new do |spec|
  spec.name          = "active_record_date_range_scopes"
  spec.version       = ActiveRecord::DateRangeScopes.version
  spec.authors       = ["Tyler Rick"]
  spec.email         = ["tyler@tylerrick.com"]

  spec.summary       = %q{Easily create ActiveRecord date range scopes}
  spec.description   = spec.summary
  spec.homepage      = "http://github.com/TylerRick/active_record_date_range_scopes"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.metadata["source_code_uri"]}/blob/master/Changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "activerecord"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "sqlite3"
end
