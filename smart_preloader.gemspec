# frozen_string_literal: true

require_relative "lib/active_record/smart_preloader"

Gem::Specification.new do |spec|
  spec.name          = "smart_preloader"
  spec.version       = ActiveRecord::SmartPreloader::VERSION
  spec.authors       = ["Serg Tyatin"]
  spec.email         = ["700@2rba.com"]

  spec.summary       = "Allows to preload associations in a smart way"
  spec.description   = "Allows to preload ActiveRecord associations in a smart way"
  spec.homepage      = "https://github.com/2rba/smart_preloader"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]
end
