# frozen_string_literal: true

require 'sinatra/base'

module Smolsrv
  class App < ::Sinatra::Base
    use ::Rack::JSONBodyParser

    set :reload_templates, false

    before do
      if request.params['_k'] != ::Smolsrv::WEBHOOK_KEY
        halt 418, "🫖"
      end
    end

    get '/' do
      "yep"
    end

    post '/api' do
      handle_incoming_message(request.params)
    end

    def initialize
      @store = Store.new

      @forward_email_conn = Faraday.new(
        url: 'https://api.forwardemail.net',
        headers: {'Content-Type' => 'application/json'},
      ) do |conn|
        conn.request :authorization, :basic, ::Smolsrv::FORWARDEMAIL_API_TOKEN , ''
      end
    end

    def handle_incoming_message(message)
      if @store.already_seen_message?(message)
        ::Smolsrv::Log.warn("already seen message id #{message['messageId']}")
        return ""
      end

      @store.record_received!(message)

      from = message['from']['value'][0]
      to = message['to']['value'][0]

      # find original received message from InReplyTo header on this message
      # - find the sent message matching the InReplyTo
      # - find the received matching the sent's orig-message-id
      in_reply_to_msg = @store.find_original_received_from_in_reply_to(message)

      candidate_recipients = Set.new(::Smolsrv::DISTRIBUTION_LIST)

      if in_reply_to_msg
        candidate_recipients << in_reply_to_msg['from']['value'][0]['address']
      end

      candidate_recipients.delete(from['address'])

      (message['cc'] || {})['value']&.each do |cc|
        candidate_recipients.delete(cc['address'])
      end

      candidate_recipients.to_a.each do |address|
        new_from = {
          'name' => from['name'],
          'address' => to['address']
        }

        send_message(message, address, new_from)
      end
    end

    def compose_forward(message, address, from)
      copied_params = ["subject", "attachments", "html", "text", "date"]

      message.slice(*copied_params).tap do |new_message|
        new_message['from'] = "#{from['name']} <#{from['address']}>"
        new_message['to'] = address
        new_message['messageId'] = "<#{SecureRandom.uuid}@#{@message_id_domain}>"
        new_message['inReplyTo'] = @store.find_sent_in_reply_to(message, address)
        new_message['headers'] = {'X-Smolsrv-Orig-Message-Id' => message['messageId']}
      end
    end

    def send_message(message, address, from)
      forward = compose_forward(message, address, from)
      ::Smolsrv::Log.debug(JSON.pretty_generate(forward))

      resp = @forward_email_conn.post('/v1/emails') do |req|
        req.body = forward.to_json
      end

      if resp.success?
        record_sent!(forward)
      end

      ::Smolsrv::Log.info("send to=#{address} message_id=#{forward['messageId']} resp=#{resp.status}")
    end
  end
end
