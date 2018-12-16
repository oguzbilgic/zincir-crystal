module Zincir
  module Storage
    module Network
      extend self

      def load_and_sync(blockchain, network)
        network.on :block do |block|
          blockchain.queue_block block
        end

        blockchain.on :block do |block|
          network.broadcast_block block if block.mined_by_us?
        end

        go_back_index = nil
        loop do
          index = go_back_index || blockchain.last.index + 1
          block = network.download_block index

          blockchain.queue_block block
          go_back_index = nil
        rescue Blockchain::BlockHashMismatch | Blockchain::BlockOnForkChain
          puts "Downloaded block's previous hash doesn't match with ours, will check previous..."
          go_back_index = go_back_index ? go_back_index -1 : index.not_nil! - 2
        rescue Blockchain::BlockNotPreferred
          network.broadcast_block blockchain.block_at index.not_nil!
          puts "Received block is disregarded #{block}"
          puts "Broadcasting the preffered block to network"
          break
        rescue
          break
        end

        puts "Finished downloading the chain from the network"
      end
    end
  end
end
