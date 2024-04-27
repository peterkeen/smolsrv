#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

require 'set'
require 'pstore'

class Smolsrv < Sinatra::Base
  use ::Rack::JSONBodyParser

  set :reload_templates, false

  def initialize
    @store = PStore.new('messages.pstore', true)

    @store.transaction do
      @store[:sent] ||= []
      @store[:received] ||= []
    end

    @distribution_list = Set.new(ENV['SMOLSRV_DISTRIBUTION_LIST'].split(',').map(&:strip))
    @message_id_domain = ENV['SMOLSRV_MESSAGE_ID_DOMAIN']

    @forward_email_conn = Faraday.new(
      url: 'https://api.forwardemail.net',
      headers: {'Content-Type' => 'application/json'},
    ) do |conn|
      conn.request :authorization, :basic, ENV['FORWARDEMAIL_API_TOKEN'], ''
    end
  end

  def already_seen_message?(message)
    @store.transaction do
      @store[:received].detect { |r| r['messageId'] == message['messageId'] }
    end
  end

  def record_received!(message)
    @store.transaction do
      @store[:received] << message
    end
  end

  def address_in_distribution_list?(address)
    @distribution_list.include?(address)
  end

  def find_received_reply(message)
    return nil if message['inReplyTo'].nil?

    orig_sent = find_sent do |m|
      m['messageId'] == message['inReplyTo']
    end

    return nil unless orig_sent
    
    @store.transaction do
      @store[:received].detect do |m|
        m['messageId'] == orig_sent['headers']['X-Smolsrv-Orig-Message-Id']
      end
    end
  end

  def find_sent(&block)
    @store.transaction do
      @store[:sent].detect do |m|
        yield m
      end
    end
  end

  def record_sent!(message)
    @store.transaction do
      @store[:sent] << message
    end
  end

  def handle_incoming_message(message)
    # if already_seen_message?(message)    
    #    STDERR.puts "already seen message id #{message['messageId']}"
    #   return ""
    # end

    # record_received!(message)

    from = message['from']['value'][0]
    to = message['to']['value'][0]

    # find original received message from InReplyTo header on this message
    # - find the sent message matching the InReplyTo
    # - find the received matching the sent's orig-message-id
    in_reply_to = find_received_reply(message)

    STDERR.puts(JSON.pretty_generate(in_reply_to))

    candidate_recipients = Set.new(@distribution_list)

    if in_reply_to
      candidate_recipients << in_reply_to['from']['value'][0]['address']
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

  def send_message(message, address, from)
    copied_params = ["subject", "attachments", "html", "text", "date"]
    in_reply_to = nil

    source = find_sent do |m|
      m['messageId'] == message['inReplyTo']
    end

    if source
      in_reply_to = source['headers']['X-Smolsrv-Orig-Message-Id']
      
      if address_in_distribution_list?(address)
        mapped = find_sent do |r| 
          r['headers']['X-Smolsrv-Orig-Message-Id'] == source['headers']['X-Smolsrv-Orig-Message-Id'] &&
            r['to'] == address
        end

        if mapped
          in_reply_to = mapped['messageId']
        end
      end
    end

    new_message = message.slice(*copied_params)
    new_message['from'] = "#{from['name']} <#{from['address']}>"
    new_message['to'] = address
    new_message['messageId'] = "<#{SecureRandom.uuid}@#{@message_id_domain}>"
    new_message['inReplyTo'] = in_reply_to
    new_message['headers'] = {'X-Smolsrv-Orig-Message-Id' => message['messageId']}

    STDERR.puts(JSON.pretty_generate(new_message))

    # resp = @forward_email_conn.post('/v1/emails') do |req|
    #   req.body = new_message.to_json
    # end

    # if resp.success?
    #   record_sent!(new_message)
    # end

#    STDERR.puts("send to=#{address} message_id=#{new_message['messageId']} resp=#{resp.status}")
  end

  post '/api' do
    handle_incoming_message(request.params)
  end
end
