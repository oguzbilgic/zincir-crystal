module Zincir
  class Node
    private class Message
      JSON.mapping(ip: String?, block: Block?)

      def initialize(@ip)
      end

      def initialize(@block : Block)
      end
    end

    include Emitter(Block -> Void)

    getter ip

    def initialize(@ip : String)
      @socket = HTTP::WebSocket.new "http://#{ip}/blocks"

      listen
      spawn @socket.run
    end

    def initialize(@socket : HTTP::WebSocket, @ip = nil)
      listen
    end

    private def listen
      @socket.on_message do |msg|
        message = Message.from_json msg

        if message.block
          emit :block, message.block.not_nil!
        end

        if message.ip != nil
          @ip = message.ip
        end
      end
    end

    def public?
      @ip != nil
    end

    def connected?
      !@socket.closed?
    end

    def to_s(io)
      io << @ip
    end

    def broadcast_block(block)
      message = Message.new block

      @socket.send message.to_json
    end

    def broadcast_host_ip(ip)
      message = Message.new ip

      @socket.send message.to_json
    end

    def known_ips
      response = HTTP::Client.get "http://#{@ip}/nodes"

      Array(String).from_json response.body
    end

    def download_block(index)
      response = HTTP::Client.get "http://#{@ip}/blocks/#{index}"

      Block.from_json response.body
    end
  end
end
