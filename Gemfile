source "https://rubygems.org"

gemspec

unless ENV["TRAVIS"]
  if RUBY_VERSION > "2.4"
    gem "pry-byebug"
  end
end
