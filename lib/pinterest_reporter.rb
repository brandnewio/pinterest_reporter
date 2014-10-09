require "pinterest_reporter/version"
require 'rubygems'

# DEPENDENCIES
require 'faraday'
require 'faraday_middleware'
require 'json'
require 'capybara'
require 'capybara/dsl'
require 'nokogiri'
require 'oj'
require 'excon'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

# PinterestReporter module (including logger)
require 'pinterest_reporter/pinterest_reporter'

# MAIN FILES
require 'pinterest_reporter/pinterest_interactions_base'
require 'pinterest_reporter/pinterest_website_caller'
require 'pinterest_reporter/pinterest_website_scraper'

module PinterestReporter
end
