require "openssl"
require "json"
require "http/client"
require "kemal"

require "./zincir/*"
require "./zincir/storage/*"

module Zincir
  VERSION = "0.1.0"

  blockchain = Blockchain.new
  network = Network.new ARGV.first?

  # Read from file system
  Storage::File.load_and_sync blockchain

  # Sync with network
  Storage::Network.load_and_sync blockchain, network

  # Start web server if public
  spawn Web.start! network, blockchain

  # Start miner if mining
  spawn Miner.start! blockchain

  sleep
end
