module Zincir
  module Storage
    module Network
      extend self

      def load_and_sync(blockchain : Blockchain, network : Zincir::Network)
        network.on_block do |block|
          blockchain.queue_block block
        end

        blockchain.on_block do |block|
          network.broadcast_block block if block.mined_by_us?
        end

        last_index = blockchain.last.index

        loop do
          last_index += 1
          block = network.download_block last_index

          if block
            blockchain.queue_block block
          else
            break
          end
        rescue
          break
        end

        puts "Finished downloading the chain from the network"
      end
    end
  end
end
