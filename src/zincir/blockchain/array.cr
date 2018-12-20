module Zincir
  class Blockchain::Array < Blockchain
    # Creates a blockchain with the first block
    def initialize
      @blocks = [Block.first]
      @queued_blocks = [] of Block
    end

    # Returns the last `Block` in the blockchain
    def last
      @blocks.last
    end

    # Returns the `Block` at *index*
    def block_at(index)
      @blocks[index]
    end

    # Queues the *block* to be added to the blockchain
    def queue_block(block)
      @queued_blocks << block
      # puts "Queue #{block} #{@queued_blocks.size}"

      until @queued_blocks.empty?
        first_block = @queued_blocks.sort_by!(&.index).shift

        add_block first_block
      end
    rescue BlockIndexTooHigh
      @queued_blocks << first_block.not_nil!
    end

    # TODO: Handle blocks with future timestamp
    private def add_block(block)
      unless block.valid?
        raise BlockNotAdded.new "Invalid block at index #{block.index}"
      end

      if block.index > next_index
        raise BlockIndexTooHigh.new
      end

      if next_index > block.index
        our_block = block_at block.index

        return if our_block.hash == block.hash

        # if this is the first block of the fork
        if our_block.previous_hash != block.previous_hash
          raise BlockOnForkChain.new
        end

        # raise if the forked chain's first block isn't better than ours
        #
        # TODO: This is not a good way to pick blocks, miner can set the time to
        # last.timestamp + 1, to make a preferable block
        if our_block.timestamp <= block.timestamp
          raise BlockNotPreferred.new "Blockchain contains a better block for index #{block.index}"
        end

        puts "Reseting chain with #{block}"
        @blocks = @blocks[0..block.index-1]
      end

      if block.previous_hash != last.hash
        # raise BlockHashMismatch.new "Hash mismatch for block at index #{block.index}"
        raise BlockOnForkChain.new
      end

      if block.difficulty != next_difficulty
        raise BlockNotAdded.new "Wrong difficulty block: #{block.difficulty} our: #{next_difficulty}"
      end

      if block.timestamp <= last.timestamp
        raise BlockNotAdded.new "Block time is wrong #{block}"
      end

      if last.difficulty != block.difficulty
        puts "Difficulty #{last.difficulty} -> #{block.difficulty}"
      end

      @blocks << block
      block_added block
    end
  end
end
