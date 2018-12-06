require "kemal"
require "./blockchain.cr"

blockchain = Blockchain.new

# logging false

get "/blocks" do
  blockchain.blocks.to_json
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

Fiber.yield
