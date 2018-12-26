module Zincir
  module Web
    DEFAULT_PORT = 9147
    DEFAULT_IP = "localhost"

    def self.start!(network, blockchain, port = nil, ip = nil)
      logging false

      before_all do |env|
        env.response.headers.add("Access-Control-Allow-Origin", "*")
      end

      get "/nodes" do
        network.public_nodes.map(&.ip).to_json
      end

      get "/blocks" do
        blockchain.last.to_json
      end

      get "/tips" do
        blockchain.try &.tips.to_json
      end

      # NOTE: Is there a more idiomatic way to check these 3 cases?
      get "/blocks/:input" do |env|
        input = env.params.url["input"]

        if input.includes? ','
          indexes = input.split(',').map(&.to_i).uniq

          blockchain.blocks_at(indexes).to_json
        elsif input.includes? ".."
          ranges = input.split ".."
          range = ranges.first.to_i..ranges.last.to_i

          blockchain.blocks_at(range).to_json
        else
          blockchain.block_at(input.to_i).to_json
        end
      end

      ws "/blocks" do |socket, env|
        network.add_node socket
      end

      port ||= DEFAULT_PORT
      if ip
        puts "Starting & broadcasting web server at #{ip}:#{port}"
        network.broadcast_host_ip "#{ip}:#{port}"
      else
        ip = DEFAULT_IP
        puts "Starting local web server at #{ip}:#{port}"
      end

      Kemal.run port
    end
  end
end
