# coding: utf-8

require "spec_helper"

describe FrScaffold do
  describe '#initialize' do
    specify do
      input = <<-EOS
### ruby first commit
Gemfileを作成する
>>>
source 'https://rubygems.org'

gem 'rspec'
gem 'guard'
gem 'guard-rspec'

gem 'ruby-debug19'

gem 'simplecov',  :require => false
gem 'simplecov-rcov',  :require => false

#gem 'active_support'
gem 'i18n'

group :development do
  gem "jeweler",  "~> 1.6.4"
end
<<<

.rvmrc作成
>>>
rvm use 1.9.3
rvm gemset use apodidae
<<<

### javascript first commit
foo.jsを作成
>>>
abc
<<<
EOS
      FrScaffold::Parser.new(input).result.should ==
        {
          "ruby" => [
            {"title" => "Gemfileを作成する", "source" => <<SOURCE1},
source 'https://rubygems.org'

gem 'rspec'
gem 'guard'
gem 'guard-rspec'

gem 'ruby-debug19'

gem 'simplecov',  :require => false
gem 'simplecov-rcov',  :require => false

#gem 'active_support'
gem 'i18n'

group :development do
  gem "jeweler",  "~> 1.6.4"
end
SOURCE1
            {"title" => ".rvmrc", "source" => <<SOURCE2},
rvm use 1.9.3
rvm gemset use apodidae
SOURCE2
          ],
          "javascript" => [
            {"title" => "foo.js", "source" => "abc"},
          ]
        }
    end
  end
end
