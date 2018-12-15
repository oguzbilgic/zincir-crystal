module Zincir
  module Web
    DEFAULT_PORT = 9147
    DEFAULT_IP = "localhost"

    def self.start!(network, blockchain, port = nil, ip = nil)

      get "/blocks" do
        blockchain.last.to_json
      end

      get "/blocks/:index" do |env|
        index = env.params.url["index"].to_i

        blockchain.block_at(index).to_json
      end

      ws "/blocks" do |socket, env|
        network.add_node env.request.host_with_port.not_nil!, socket
      end

      port ||= DEFAULT_PORT
      ip ||= DEFAULT_IP
      puts "Starting web server at port #{ip}:#{port}"
      network.broadcast_node_ip "#{ip}:#{port}"

      logging false
      Kemal.run port
    end
  end
end
