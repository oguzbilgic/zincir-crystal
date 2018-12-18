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

        if network.public_nodes.empty?
          puts "Can't download or broadcast to network, no public nodes"
          return
        end

        network_last_block = network.last_block
        if blockchain.last.index < network_last_block.index
          download blockchain, network
        elsif blockchain.last.index > network_last_block.index
          broadcast blockchain, network, network_last_block.index
        end
      end

      private def broadcast(blockchain, network, from_index)
        loop do
          break if blockchain.last.index < from_index

          block = blockchain.block_at from_index
          network.broadcast_block block

          puts "Broadcasting local #{block}"
          from_index +=1
        end
      end

      private def download(blockchain, network)
        go_back_index = nil
        loop do
          index = go_back_index || blockchain.last.index + 1
          block = network.block_at index

          blockchain.queue_block block
          go_back_index = nil
        rescue Blockchain::BlockOnForkChain
          puts "Forked chain block #{block}"
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
