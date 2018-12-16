module Zincir
  module Storage
    module File
      def self.load_and_sync(blockchain)
        Dir.mkdir ".blocks" unless ::File.exists? ".blocks"

        blockchain.on :block do |block|
          ::File.write ".blocks/#{block.hash}", block.to_json
        end

        Dir.open(".blocks/").each_child do |filename|
          file = ::File.read ".blocks/#{filename}"
          block = Block.from_json file
          blockchain.queue_block block
        rescue Blockchain::BlockNotAdded
          ::File.delete ".blocks/#{block.hash}"
          puts "Filesystem block is disregarded, deleting file.."
          next
        end

        puts "Finished reading the chain from file system"
      end
    end
  end
end
