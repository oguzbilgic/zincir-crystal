require "./blockchain.cr"
require "./chain_storage.cr"
require "./network.cr"
require "./miner.cr"
require "./web.cr"

port = Random.rand(1000) + 4000
blockchain = Blockchain.new
network = Network.new blockchain, "http://localhost:#{port}", ARGV.first?
miner = Miner.new blockchain
chain_storage = ChainStorage.new blockchain

# Read from file system
chain_storage.read

# Sync with network
network.download_chain

# Start web server if public
spawn do
  start_web! port, network, blockchain
end

# Start miner if mining
spawn do
  miner.run!
end

sleep
