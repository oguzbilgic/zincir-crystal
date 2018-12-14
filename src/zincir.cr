require "openssl"
require "json"
require "http/client"
require "kemal"

require "./zincir/*"
require "./zincir/storage/*"

module Zincir
  VERSION = "0.1.0"

  blockchain = Blockchain.new

  # Read from file system
  file_storage = Storage::File.new blockchain
  file_storage.load_and_start

  # Sync with network
  network = Network.new ARGV.first?
  network_storage = Storage::Network.new blockchain, network
  network_storage.load_and_start

  # Start web server if public
  spawn do
    Web.start! network, blockchain
  end

  # Start miner if mining
  spawn do
    Miner.start! blockchain
  end

  sleep
end
