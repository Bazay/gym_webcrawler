# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/gym_webcrawler/version'
require_relative 'lib/extensions/capybara'

Gem::Specification.new do |spec|
  spec.name          = "gym_webcrawler"
  spec.version       = GymWebcrawler::VERSION
  spec.authors       = ["Baron"]
  spec.email         = ["baronbloomer@gmail.com"]

  spec.summary       = 'Gym lesson booker'
  spec.description   = 'Automatically book gym appointments'
  spec.homepage      = 'http://baronbloomer.com'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = Dir['lib/**/*.rb']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rufus-scheduler'
  spec.add_development_dependency 'chronic'
  spec.add_development_dependency 'poltergeist'
  spec.add_development_dependency 'capybara'
end
