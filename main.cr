require "kemal"
require "./blockchain.cr"

blockchain = Blockchain.new

# logging false

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
  Kemal.run
end

spawn do
  blockchain.work!
end

sleep
