# frozen_string_literal: true

require_relative "lib/omniauth/nft/version"

Gem::Specification.new do |spec|
  spec.name = "omniauth-nft"
  spec.version = OmniAuth::Nft::VERSION
  spec.authors = ["David J Parrott"]
  spec.email = ["valthon@nothlav.net"]

  spec.summary = "OmniAuth strategy for authenticating via NFT ownership"
  spec.homepage = "https://github.com/valthon/omniauth-nft"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/valthon/omniauth-nft"
  spec.metadata["changelog_uri"] = "https://github.com/valthon/omniauth-nft/blob/trunk/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "eth", "~> 0.4"
  spec.add_dependency "nft_checker", "~> 0.3"
  spec.add_dependency "omniauth", "~> 2.0"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-rails", "~> 2.13"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 0.6"

  spec.add_runtime_dependency "rails", ">= 6.0.0"
end
