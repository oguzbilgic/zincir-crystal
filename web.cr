require "kemal"

require "./block.cr"

def start_web!(port, network, blockchain)
  post "/connect" do |env|
    puts "Node connected: #{env.params.body["id"]}"
    network.add_node env.params.body["id"], true
  end

  post "/relay" do |env|
    block = Block.from_json env.request.body.not_nil!
    blockchain.add_relayed_block block
  end

  get "/blocks" do
    blockchain.last.to_json
  end

  get "/blocks/:index" do |env|
    index = env.params.url["index"].to_i

    blockchain.block_at(index).to_json
  end

  puts "Starting web server at port #{port}"
  logging false
  Kemal.run port
end
