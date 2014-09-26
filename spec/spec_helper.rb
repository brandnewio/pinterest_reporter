# encoding UTF-8

require 'rubygems'
require 'rspec'

$:.unshift File.expand_path('../../lib', __FILE__)

require 'pinterest_reporter'

RSpec.configure do |c|
  c.order = "random"
  c.tty = true
  c.color = true
end
