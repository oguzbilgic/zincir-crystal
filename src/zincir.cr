require "openssl"
require "json"
require "http/client"
require "kemal"

require "./zincir/*"
require "./zincir/storage/*"

module Zincir
  VERSION = "0.1.0"

  port = Random.rand(1000) + 4000
  blockchain = Blockchain.new
  miner = Miner.new blockchain
  network = Network.new ARGV.first?
  file_storage = Storage::File.new blockchain
  network_storage = Storage::Network.new blockchain, network

  # Read from file system
  file_storage.load_and_start

  # Sync with network
  network_storage.load_and_start

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
