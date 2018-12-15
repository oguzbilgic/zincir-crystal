module Zincir
  class Node
    include Emitter(Block -> Void)

    def initialize(@ip)
      @socket = HTTP::WebSocket.new URI.parse "#{@ip}/blocks"

      listen
      spawn @socket.run
    end

    def initialize(@ip : String, @socket)
      listen
    end

    private def listen
      @socket.on_message do |msg|
        emit :block, Block.from_json msg
      end
    end

    def to_s(io)
      io << @socket
    end

    def broadcast_block(block)
      @socket.send block.to_json
    end

    def download_block(index)
      response = HTTP::Client.get "#{@ip}/blocks/#{index}"

      Block.from_json response.body
    end
  end
end
