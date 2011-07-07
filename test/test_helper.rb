require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

ENV["RACK_ENV"] = "test"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rack-oauth2_utils'
require "rack/test"


require 'minitest/autorun'