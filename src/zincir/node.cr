module Zincir
  class Node
    def initialize(@ip)
      uri = URI.parse "#{@ip}/blocks"
      @socket = HTTP::WebSocket.new uri

      spawn @socket.run
    end

    def initialize(@ip : String, @socket)
    end

    def to_s(io)
      io << @socket
    end

    def on_block(&block : Block -> Void)
      @socket.on_message do |msg|
        b = Block.from_json msg
        block.call b
      end
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
