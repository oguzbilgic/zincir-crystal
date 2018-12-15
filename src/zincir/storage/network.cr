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

        last_index = blockchain.last.index

        loop do
          last_index += 1
          block = network.download_block last_index

          blockchain.queue_block block
        rescue
          break
        end

        puts "Finished downloading the chain from the network"
      end
    end
  end
end
