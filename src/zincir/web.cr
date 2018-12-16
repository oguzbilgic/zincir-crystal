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

      get "/blocks/:index" do |env|
        index = env.params.url["index"].to_i

        blockchain.block_at(index).to_json
      end

      ws "/blocks" do |socket, env|
        network.add_node socket
      end

      port ||= DEFAULT_PORT
      if ip
        puts "Starting & broadcasting web server at port #{ip}:#{port}"
        network.broadcast_host_ip "#{ip}:#{port}"
      else
        puts "Starting local web server at port #{ip}:#{port}"
        ip = DEFAULT_IP
      end

      Kemal.run port
    end
  end
end
