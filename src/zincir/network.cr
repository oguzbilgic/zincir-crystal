module Zincir
  class Network
    include Emitter(Block -> Void)

    TESTNET_SEED_HOST = "testnet.zincir.xyz:9147"

    @host_ip : String? = nil
    @nodes = [] of Node

    # Creates the `Network` with the given *seed_node_ip* as the first node.
    #
    # Spawns a fiber that periodically explores the connected nodes for new nodes.
    def initialize(seed_node_ip = nil)
      add_node seed_node_ip if seed_node_ip

      spawn explore_nodes!
    end

    # Creates a new `Node` with the given *websocket* connection
    def add_node(websocket : HTTP::WebSocket)
      add_node Node.new websocket
    end

    # Creates a new `Node` with the given *ip* if it hasn't been connected to already
    def add_node(ip : String)
      return if @nodes.map(&.ip).includes? ip

      return if @host_ip == ip

      add_node Node.new ip
    end

    # Adds the given node to the `Network`
    def add_node(node : Node)
      node.on :block do |block|
        emit :block, block
      end

      @nodes << node
      puts "New connection #{node} count: #{@nodes.size}"
    end

    # Returns a list connected public node
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

    def last_block
      public_nodes.sample.last_block
    end

    def block_at(index)
      public_nodes.sample.block_at index
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
  end
end
