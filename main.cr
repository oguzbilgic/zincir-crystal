require "kemal"
require "http/client"

require "./blockchain.cr"

port = Random.rand(1000) + 4000
blockchain = Blockchain.new

post "/relay" do |env|
  block = Block.from_json env.request.body.not_nil!
  puts "New block received for index " + block.index.to_s
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

spawn do
  blockchain.work!
end

sleep
