require "kemal"

require "./block.cr"

def start_web!(port, network, blockchain)
  get "/blocks" do
    blockchain.last.to_json
  end

  get "/blocks/:index" do |env|
    index = env.params.url["index"].to_i

    blockchain.block_at(index).to_json
  end

  ws "/blocks" do |socket|
    network.add_node_by_socket socket
  end

  puts "Starting web server at port #{port}"
  logging false
  Kemal.run port
end
