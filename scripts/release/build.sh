#!/usr/bin/env bash
set -e

cd buildpack
git tag v`cat VERSION`
export BUNDLE_GEMFILE=cf.Gemfile
bundle install
bundle exec buildpack-packager uncached
bundle exec buildpack-packager cached

timestamp=$(date +%s)
ruby <<RUBY
require "fileutils"
Dir.glob("*.zip").map do |filename|
  filename.match(/(.*)_buildpack(-cached)?-v(.*).zip/) do |match|
    language = match[1]
    cached = match[2]
    version = match[3]
    FileUtils.mv(filename, "#{language}_buildpack#{cached}-v#{version}+$timestamp.zip")
  end
end
RUBY
