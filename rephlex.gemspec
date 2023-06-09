# frozen_string_literal: true

require_relative "lib/rephlex/version"

Gem::Specification.new do |spec|
  spec.name = "rephlex"
  spec.version = Rephlex::VERSION
  spec.authors = ["roman"]
  spec.email = ["roman.nturner@gmail.com"]

  spec.summary =
    "Fast and Fun. A ruby micro-framework built on Roda, Sequel, and Phlex components."

  spec.description = <<-DESCRIPTION
  Fast and Fun. A ruby micro-framework built on Roda, Sequel, and Phlex
  DESCRIPTION

  spec.homepage = "https://github.com/simply-ruby/rephlex"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(__dir__) do
      `git ls-files -z`.split("\x0")
        .reject do |f|
          (f == __FILE__) ||
            f.match(
              %r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)}
            )
        end
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "reverse_markdown"
  spec.add_dependency "dry-inflector"
  spec.add_dependency "tty-prompt"
  spec.add_dependency "tty-font"
  spec.add_dependency "tty-file"
  spec.add_dependency "tomlrb"
  spec.add_dependency "pastel"
  spec.add_dependency "thor"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
