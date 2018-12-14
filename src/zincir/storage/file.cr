module Zincir
  module Storage
    class File < Base
      def initialize(@blockchain : Blockchain)
        Dir.mkdir ".blocks" unless ::File.exists? ".blocks"

        @blockchain.on_block do |block|
          ::File.write ".blocks/#{block.hash}", block.to_json
        end
      end

      def load_and_start
        Dir.open(".blocks/").each_child do |filename|
          file = ::File.read ".blocks/#{filename}"
          block = Block.from_json file
          @blockchain.queue_block block
        end

        puts "Finished reading the chain from file system"
      end
    end
  end
end
