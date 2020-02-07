# frozen_string_literal: true

# Disable rubocop checks for the .gemspec
# I'll take the output from 'bundle gem new' to be authoritative
# rubocop:disable all

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faker_maker/version'

Gem::Specification.new do |spec|
  spec.name          = 'faker_maker'
  spec.version       = FakerMaker::VERSION
  spec.authors       = ['Nigel Brookes-Thomas']
  spec.email         = ['nigel@brookes-thomas.co.uk']

  spec.summary       = 'FakerMaker bakes fakes.'
  spec.description   = 'FakerMaker is a simple factory builder so you can throw away your fixtures and generate test data instead.'
  spec.homepage      = 'https://billyruffian.github.io/faker_maker/'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata['allowed_push_host'] = 'TODO: Set to 'http://mygemserver.com''

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/BillyRuffian/faker_maker'
    spec.metadata['changelog_uri'] = 'https://github.com/BillyRuffian/faker_maker/releases'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 5.2', '< 7'

  spec.add_development_dependency 'bundler',       '~> 2.0'
  spec.add_development_dependency 'faker',         '~> 2.1'
  spec.add_development_dependency 'guard',         '~> 2.16'
  spec.add_development_dependency 'guard-bundler', '~> 2.2'
  spec.add_development_dependency 'guard-rubocop', '~> 1.3'
  spec.add_development_dependency 'guard-rspec',   '~> 4.7'
  spec.add_development_dependency 'pry',           '~> 0.12'
  spec.add_development_dependency 'rake',          '~> 13.0'
  spec.add_development_dependency 'rspec',         '~> 3.8'
  spec.add_development_dependency 'rubocop',       '~> 0.68'
  spec.add_development_dependency 'simplecov',     '~> 0.16'
  spec.add_development_dependency 'coveralls',     '~> 0.8'
end
