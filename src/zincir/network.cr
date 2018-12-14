module Zincir
  class Network
    def initialize(seed_node_ip = nil)
      @nodes = [] of Node
      @on_block_callbacks = [] of Block -> Void

      add_node seed_node_ip if seed_node_ip
    end

    def add_node(host_with_port : String, socket : HTTP::WebSocket)
      node = Node.new "http://#{host_with_port}" , socket

      add_node node
    end

    def add_node(ip : String)
      add_node Node.new ip
    end

    def add_node(node : Node)
      node.on_block do |block|
        @on_block_callbacks.each do |callback|
          callback.call block
        end
      end

      @nodes << node
      puts "Connected to node: #{node}"
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

    def on_block(&block : Block -> Void)
      @on_block_callbacks << block
    end
  end
end
