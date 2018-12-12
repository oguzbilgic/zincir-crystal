require "http/client"

require "./node.cr"

class Network
  def initialize(@blockchain : Blockchain, @our_ip : String, seed_node_ip = nil)
    @nodes = [] of Node

    add_node_by_ip seed_node_ip if seed_node_ip

    @blockchain.on_block { |b| broadcast_block b if b.solved }
  end

  def add_node_by_socket(socket)
    node = Node.new "" , socket

    add_node node
  end

  def add_node_by_ip(ip, incoming = false)
    node = Node.new ip

    add_node node
  end

  def add_node(node)
    node.on_block do |block|
      # puts "Block received #{block}"
      @blockchain.add_relayed_block block
    end

    @nodes << node
    puts "Connected to node: #{node}"
  end

  def broadcast_block(block)
    @nodes.each do |node|
      # puts "Broadcasting #{block} to #{node}"
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
    rescue
      break
    end

    puts "Finished downloading the chain"
  end
end
