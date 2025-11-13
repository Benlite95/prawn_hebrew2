# frozen_string_literal: true

require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name          = 'prawn_hebrew'
  spec.version       = PrawnHebrew::VERSION
  spec.authors       = ['Ben Lite']
  spec.email         = ['benlite96@gmail.com']
  spec.summary       = 'Hebrew Text in Prawn'
  spec.description   = 'Working with hebrew words in prawn'
  spec.homepage      = 'https://github.com/Benlite95/prawn_hebrew2'
  spec.license       = 'MIT'

  spec.files         = ['lib/prawn_hebrew.rb', 'lib/version.rb']
  spec.require_paths = ['lib']

  spec.metadata = {
    'homepage_uri'    => 'https://github.com/Benlite95/prawn_hebrew2',
    'source_code_uri' => 'https://github.com/Benlite95/prawn_hebrew2',
    'changelog_uri'   => 'https://github.com/Benlite95/prawn_hebrew2/releases',
    'bug_tracker_uri' => 'https://github.com/Benlite95/prawn_hebrew2/issues',
    'documentation_uri' => 'https://rubydoc.info/gems/prawn_hebrew'
  }

  spec.required_ruby_version = '>= 2.7'
  spec.required_rubygems_version = '>= 3.0'

  spec.add_dependency 'prawn', '>= 2.0'
end
