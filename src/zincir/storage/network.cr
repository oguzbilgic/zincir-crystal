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

        blockchain_last = blockchain.last
        network_last = network.last_block

        if blockchain_last.hash != network_last.hash
          puts "Doesn't have same last block"
          lowest = Math.min blockchain_last.index, network_last.index
          mutual_block = find_mutual_block blockchain, network, lowest

          if blockchain_last.index > network_last.index
            broadcast blockchain, network, mutual_block.index + 1
          elsif blockchain_last.index <= network_last.index
            download blockchain, network, mutual_block.index
          end
        end

        check_sync_status blockchain, network
      end

      def find_mutual_block(blockchain, network, lowest)
        loop do
          our_block = blockchain.block_at lowest
          net_block = network.block_at lowest

          return our_block if our_block.hash == net_block.hash

          lowest -= 1
        end
      end

      private def broadcast(blockchain, network, starting_from_index)
        puts "Broadcasting chain staring from #{starting_from_index}"
        loop do
          break if blockchain.last.index < starting_from_index

          block = blockchain.block_at starting_from_index
          network.broadcast_block block

          puts "Broadcasting local #{block}"
          starting_from_index +=1
        end
      end

      private def download(blockchain, network, ending_index)
        index = network.last_block.index
        loop do
          break if ending_index > index
          # puts "Fetching index: #{index}"
          block = network.block_at ending_index

          blockchain.queue_block block
          ending_index +=1
        rescue Blockchain::BlockOnForkChain
          puts "BlockOnForkChain #{block}"
          next
        rescue Blockchain::BlockNotPreferred
          puts "BlockNotPreferred #{block}"
          broadcast blockchain, network, block.not_nil!.index
          break
        end

        puts "Finished downloading the chain from the network"
      end

      def check_sync_status(blockchain, network)
        puts "Checking network sync status..."
        sleep 5
        last_network = network.last_block
        our_block = blockchain.last

        raise "Not in sync" if last_network.hash != our_block.hash
        puts "Blockchain is in sync with the network"
      end
    end
  end
end
