require "./blockchain.cr"
require "./network.cr"
require "./web.cr"

port = Random.rand(1000) + 4000
blockchain = Blockchain.new
network = Network.new blockchain, "http://localhost:#{port}", ARGV.first?

spawn do
  start_web! port, network, blockchain
end

network.download_chain

spawn do
  blockchain.work!
end

sleep
