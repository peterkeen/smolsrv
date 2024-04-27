
require 'bundler/setup'
Bundler.require(:default)

require './lib/smolsrv'

run Smolsrv::App.new
