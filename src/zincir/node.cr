module Zincir
  class Node
    private class Message
      JSON.mapping(ip: String?, block: Block?)

      def initialize(@ip : String? = nil, @block : Block? = nil)
      end
    end

    include Emitter(Block -> Void)

    getter ip

    # Creates a `Node` with the given *ip* and connects via websocket
    def initialize(@ip : String)
      @socket = HTTP::WebSocket.new "http://#{ip}/blocks"

      listen
      spawn do
        @socket.run
      rescue e
        "Node.socket error: #{e}"
      end
    end

    # Creates a `Node` with the given *socket* connection
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

    def on_close(&block)
      @socket.on_close do
        block.call
      end
    end

    # Returns true if the `Node` is publicly accessible via it's `#ip`
    def public?
      @ip != nil
    end

    # Returns true if the `#socket` is open
    def connected?
      !@socket.closed?
    end

    def to_s(io)
      @ip ? io << @ip : io << "private node"
    end

    def broadcast_block(block)
      message = Message.new block: block

      @socket.send message.to_json
    end

    def broadcast_host_ip(ip)
      message = Message.new ip: ip

      @socket.send message.to_json
    end

    def known_ips
      response = HTTP::Client.get "http://#{@ip}/nodes"

      Array(String).from_json response.body
    end

    def last_block
      response = HTTP::Client.get "http://#{@ip}/blocks"

      Block.from_json response.body
    end

    def block_at(index)
      response = HTTP::Client.get "http://#{@ip}/blocks/#{index}"

      Block.from_json response.body
    end

    def blocks_at(indexes : Range | Array(Int32))
      indexes = indexes.is_a?(Range) ? indexes.to_s : indexes.join ','

      response = HTTP::Client.get "http://#{@ip}/blocks/#{indexes}"

      Array(Block).from_json response.body
    end
  end
end
