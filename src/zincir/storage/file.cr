module Zincir
  module Storage
    module File
      def self.load_and_sync(blockchain)
        Dir.mkdir ".blocks" unless ::File.exists? ".blocks"

        blockchain.on :block do |block|
          ::File.write ".blocks/#{block.hash}", block.to_json
        end

        blocks = Dir.open(".blocks/").children.map do |filename|
          file = ::File.read ".blocks/#{filename}"
          Block.from_json file
        end

        block_size = blocks.size
        blocks = blocks.sort_by!(&.index)

        loop do
          break if blocks.empty?

          block = blocks.shift

          blockchain.queue_block block
        rescue Blockchain::BlockNotPreferred
          # TODO: delete the file
          puts "Notpreferred #{block}"
        rescue Blockchain::BlockOnForkChain
          # TODO: delete the file
          puts "BlockOnForkChain #{block}"
        end

        puts "#{block_size} blocks are read from the file system"
        puts "Finished reading the chain from file system"
      end
    end
  end
end
