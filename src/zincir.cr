require "./zincir/*"

module Zincir
  VERSION = "0.1.0"

  port = Random.rand(1000) + 4000
  blockchain = Blockchain.new
  miner = Miner.new blockchain
  chain_storage = ChainStorage.new blockchain
  network = Network.new ARGV.first?
  network_storage = NetworkStorage.new blockchain, network

  # Read from file system
  chain_storage.read

  # Sync with network
  network_storage.download_chain

  # Start web server if public
  spawn do
    start_web! port, network, blockchain
  end

  # Start miner if mining
  spawn do
    miner.run!
  end

  sleep
end
