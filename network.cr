require "http/client"

class Network
  def initialize(@blockchain : Blockchain, @our_ip : String, node = nil)
    if node
      @nodes = [node]
      add_node(node)
    else
      @nodes = [] of String
    end

    @blockchain.on_solve { |b| broadcast_block b }
  end

  def add_node(node)
    form = "ip=#{@our_ip}"
    HTTP::Client.post "#{node}/connect", form: form
    puts "Connected seed server: #{node}"
  end

  def broadcast_block(block)
    @nodes.each do |node|
      HTTP::Client.post "#{node}/relay", form: block.to_json
    end
  end

  def download_chain
    return if @nodes.empty?

    last_index = @blockchain.last.index

    loop do
      last_index += 1
      response = HTTP::Client.get "#{@nodes.first}/blocks/#{last_index}"

      break if response.status_code != 200

      block = Block.from_json response.body
      @blockchain.add_relayed_block block
      puts "Downloaded #{block}"
    end

    puts "Finished downloading the chain"
  end
end
