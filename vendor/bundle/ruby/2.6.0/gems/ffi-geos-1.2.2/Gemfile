source 'https://rubygems.org'

gemspec

gem 'minitest'
gem 'minitest-reporters'
gem 'rake', '~> 10.0'
gem 'rdoc', '~> 3.12'

platforms :rbx do
  gem 'rubinius-developer_tools'
  gem 'rubysl', '~> 2.0'
end

if RUBY_VERSION >= '1.9'
  gem 'guard'
  gem 'guard-minitest'
  gem 'simplecov'
end

if File.exist?('Gemfile.local')
  instance_eval File.read('Gemfile.local')
end
