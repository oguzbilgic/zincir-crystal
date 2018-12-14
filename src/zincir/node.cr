require "http/client"

class Zincir::Node
  def initialize(@ip : String)
    uri = URI.parse "#{@ip}/blocks"
    @socket = HTTP::WebSocket.new uri

    spawn do
      @socket.not_nil!.run
    end
  end

  def initialize(@ip : String, @socket)
  end

  def to_s(io)
    io << @socket
  end

  def on_block(&block : Block -> Void)
    @socket.not_nil!.on_message do |msg|
      b = Block.from_json msg
      block.call b
    end
  end

  def broadcast_block(block)
    @socket.not_nil!.send block.to_json
  end

  def download_block(index)
    response = HTTP::Client.get "#{@ip}/blocks/#{index}"

    Block.from_json response.body
  end
end
