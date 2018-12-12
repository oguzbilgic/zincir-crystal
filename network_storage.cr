require "http/client"

class NetworkStorage
  def initialize(@blockchain : Blockchain, @network : Network)
    @network.on_block do |block|
      @blockchain.queue_block block
    end

    @blockchain.on_block do |block|
      @network.broadcast_block block if block.solved
    end
  end

  def download_chain
    last_index = @blockchain.last.index

    loop do
      last_index += 1
      block = @network.download_block last_index

      break unless block

      @blockchain.queue_block block
    end

    puts "Finished downloading the chain from the network"
  end
end
