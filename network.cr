require "http/client"

require "./node.cr"

class Network
  def initialize(@blockchain : Blockchain, @our_ip : String, seed_node_ip = nil)
    @nodes = [] of Node

    add_node seed_node_ip if seed_node_ip

    @blockchain.on_solve { |b| broadcast_block b }
  end

  def add_node(ip, incoming = false)
    node = Node.new ip
    @nodes << node

    return if incoming

    node.connect(@our_ip)
    puts "Connecting to node: #{node}"
  end

  def broadcast_block(block)
    @nodes.each do |node|
      node.broadcast_block block
    rescue
      next
    end
  end

  def download_chain
    return if @nodes.empty?

    last_index = @blockchain.last.index

    loop do
      last_index += 1
      block = @nodes.first.download_block last_index

      @blockchain.add_relayed_block block
      puts "Downloaded #{block}"
    rescue
      break
    end

    puts "Finished downloading the chain"
  end
end
