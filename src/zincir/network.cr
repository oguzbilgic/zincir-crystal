module Zincir
  class Network
    include Emitter(Block -> Void)

    TESTNET_SEED_HOST = "testnet.zincir.xyz:9147"

    @host_ip : String? = nil
    @nodes = [] of Node

    def initialize(seed_node_ip = nil)
      add_node seed_node_ip if seed_node_ip

      spawn explore_nodes!
    end

    def add_node(socket : HTTP::WebSocket)
      add_node Node.new socket
    end

    def add_node(ip : String)
      return if @nodes.map(&.ip).includes? ip

      add_node Node.new ip
    end

    def add_node(node : Node)
      node.on :block do |block|
        emit :block, block
      end

      @nodes << node
      puts "New connection #{node} count: #{@nodes.size}"
    end

    private def explore_nodes!
      loop do

        all_ips = public_nodes.map(&.known_ips).flatten
        new_ips = all_ips - public_nodes.map &.ip - [@host_ip]

        new_ips.each do |ip|
          add_node ip
        end

        sleep 10
      end
    end

    def public_nodes
      @nodes.select &.public?
    end

    def broadcast_host_ip(ip)
      @host_ip = ip

      @nodes.each do |node|
        node.broadcast_host_ip ip
      end
    end

    def broadcast_block(block)
      @nodes.each do |node|
        node.broadcast_block block
      rescue
        next
      end
    end

    def download_block(index)
      @nodes.sample.download_block index
    end
  end
end
