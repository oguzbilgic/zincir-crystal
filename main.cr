require "kemal"
require "http/client"

require "./blockchain.cr"
require "./network.cr"

port = Random.rand(1000) + 4000
blockchain = Blockchain.new
network = Network.new blockchain, "http://localhost:#{port}", ARGV.first?

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

spawn do
  puts "Starting web server at port " + port.to_s
  logging false
  Kemal.run port
end

network.download_chain

spawn do
  blockchain.work!
end

sleep
