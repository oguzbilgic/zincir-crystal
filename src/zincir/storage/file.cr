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

        until blocks.empty?
          blockchain.queue_block blocks.shift
        end

        puts "Finished reading #{block_size} from file system"
      end
    end
  end
end
