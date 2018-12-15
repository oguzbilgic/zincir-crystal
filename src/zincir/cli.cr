module Zincir
  module Cli
    extend self

    def run!
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
  end
end
