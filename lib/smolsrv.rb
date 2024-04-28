require 'bundler/setup'
Bundler.require(:default)

require 'set'
require 'pstore'

module Smolsrv
  DISTRIBUTION_LIST = Set.new(ENV.fetch('SMOLSRV_DISTRIBUTION_LIST').split(',').map(&:strip)).freeze
  MESSAGE_ID_DOMAIN = ENV.fetch('SMOLSRV_MESSAGE_ID_DOMAIN').freeze
  DATA_PATH = ENV.fetch('SMOLSRV_DATA_PATH', '.').freeze
  FORWARDEMAIL_API_TOKEN = ENV.fetch('FORWARDEMAIL_API_TOKEN').freeze
  WEBHOOK_KEY = ENV.fetch('SMOLSRV_WEBHOOK_KEY').freeze
end

require_relative './smolsrv/log'
require_relative './smolsrv/store'
require_relative './smolsrv/app'
