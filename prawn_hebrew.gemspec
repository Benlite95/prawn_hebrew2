# frozen_string_literal: true

require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name          = 'prawn_hebrew'
  spec.version       = PrawnHebrew::VERSION
  spec.authors       = ['Ben Lite']
  spec.email         = ['benlite96@gmail.com']
  spec.summary       = 'Hebrew Text in Prawn'
  spec.description   = 'Working with hebrew words in prawn'
  spec.homepage      = 'https://rubygems.org/gems/prawn_hebrew'
  spec.license       = 'MIT'

  spec.files         = ['lib/prawn_hebrew.rb', 'lib/version.rb']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 0'
  spec.required_rubygems_version = '>= 0'
end
