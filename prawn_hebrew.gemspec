require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name          = "prawn_hebrew"
  spec.version       = PrawnHebrew::VERSION
  spec.authors       = ["Benlite95"]
  spec.email         = ["your-email@example.com"]

  spec.summary       = "Hebrew text support for Prawn PDF"
  spec.description   = "Add Hebrew and bidirectional text support to Prawn PDF library"
  spec.homepage      = "https://github.com/Benlite95/prawn_hebrew2"
  spec.license       = "MIT"
  
  spec.required_ruby_version = ">= 2.6.0"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_dependency "prawn", "~> 2.4"
  
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Benlite95/prawn_hebrew2"
end
