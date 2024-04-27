# frozen_string_literal: true

module Smolsrv
  class Store
    def initialize
      @store = PStore.new(File.join(::Smolsrv::DATA_PATH, 'messages.pstore'), true)

      @store.transaction do
        @store[:sent] ||= []
        @store[:received] ||= []
      end
    end

    def already_seen_message?(message)
      find_received do |r|
        r['messageId'] == message['messageId']
      end
    end

    def find_original_received_from_in_reply_to(message)
      return nil if message['inReplyTo'].nil?
  
      orig_sent = find_sent do |m|
        m['messageId'] == message['inReplyTo']
      end
  
      return nil unless orig_sent

      find_received do |r|
        r['messageId'] == orig_sent['headers']['X-Smolsrv-Orig-Message-Id']
      end
    end

    def find_sent_in_reply_to(message, address)
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
  
      in_reply_to
    end
  
    def record_received!(message)
      @store.transaction do
        @store[:received] << strip_message(message)
      end
    end
  
    def record_sent!(message)
      @store.transaction do
        @store[:sent] << strip_message(message)
      end
    end

    private

    def find_sent(&block)
      @store.transaction do
        @store[:sent].detect do |m|
          yield m
        end
      end
    end

    def find_received(&block)
      @store.transaction do
        @store[:received].detect do |m|
          yield m
        end
      end
    end

    def address_in_distribution_list?(address)
      ::Smolsrv::DISTRIBUTION_LIST.include?(address)
    end

    def strip_message(message)
      message.dup.tap do |stripped|
        ['raw', 'text', 'html', 'headers', 'textAsHtml', 'attachments'].each do |key|
          stripped.delete(key)
        end
      end
    end
  end
end
