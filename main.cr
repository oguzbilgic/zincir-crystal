require "./blockchain.cr"
require "./network.cr"
require "./web.cr"

port = Random.rand(1000) + 4000
blockchain = Blockchain.new
network = Network.new blockchain, "http://localhost:#{port}", ARGV.first?

Dir.open(".blocks/").each_child do |filename|
  file = File.read ".blocks/#{filename}"
  block = Block.from_json file
  blockchain.add_relayed_block block
end

blockchain.on_block do |block|
  Dir.mkdir ".blocks" unless File.exists? ".blocks"
  File.write ".blocks/#{block.hash}", block.to_json
end

network.download_chain

spawn do
  start_web! port, network, blockchain
end

spawn do
  blockchain.work!
end

sleep
