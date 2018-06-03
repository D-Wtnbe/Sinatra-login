# coding: utf-8
Encoding.default_external = 'utf-8'
require 'rubygems'
require 'bundler'
Bundler.require
require 'user.rb'
run Sinatra::Application
