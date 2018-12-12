require "http/client"

class Node
  def initialize(@ip : String)
  end

  def to_s(io)
    io << @ip
  end

  def connect(our_ip)
    HTTP::Client.post "#{@ip}/connect", form: "ip=#{our_ip}"
  rescue
  end

  def broadcast_block(block)
    HTTP::Client.post "#{@ip}/relay", form: block.to_json
  rescue
  end

  def download_block(index)
    response = HTTP::Client.get "#{@ip}/blocks/#{index}"

    Block.from_json response.body
  end
end
