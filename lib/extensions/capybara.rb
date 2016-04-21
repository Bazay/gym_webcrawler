require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
options = { 
  js_errors: false,
  timeout: 60,
  phantomjs_logger: StringIO.new,
  logger: nil,
  phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'],
  debug: false
}
Capybara.register_driver(:poltergeist) do |app|
  Capybara::Poltergeist::Driver.new app, options
end

Capybara.save_path = "/tmp/screenshots/"
