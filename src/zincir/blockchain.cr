require "./difficulty"

module Zincir
  class Blockchain
    class BlockNotAdded < ::Exception end
    class BlockIndexTooHigh < BlockNotAdded end
    class BlockNotPreferred < BlockNotAdded end
    class BlockOnForkChain  < BlockNotAdded end

    # Desired time between blocks
    BLOCK_DURATION   = 60.0
    # Number of blocks between difficulty adjustments
    UPDATE_FREQUENCY =   60

    include Emitter(Block -> Void)

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

    # Returns the index of the expected `Block`
    def next_index
      last.index + 1
    end

    # Returns the required difficulty for the next `Block`
    def next_difficulty
      return last.difficulty if last.index == UPDATE_FREQUENCY - 1

      return last.difficulty if next_index % UPDATE_FREQUENCY > 0

      first = block_at last.index - UPDATE_FREQUENCY + 1
      duration = last.timestamp - first.timestamp
      desired_duration = (BLOCK_DURATION * (UPDATE_FREQUENCY - 1))

      Difficulty.calculate last.difficulty, duration, desired_duration
    end

    # Queues the *block* to be added to the blockchain
    def queue_block(block)
      @queued_blocks << block

      until @queued_blocks.empty?
        first_block = @queued_blocks.sort_by!(&.index).shift

        add_block first_block
      end
    rescue BlockIndexTooHigh
      @queued_blocks << first_block.not_nil!
    end

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
        if our_block.timestamp < block.timestamp
          raise BlockNotPreferred.new "Blockchain contains a better block for index #{block.index}"
        end

        puts "Reseting chain with #{block}"
        @blocks = @blocks[0..block.index]
        @blocks << block
        emit :block, block
        return
      end

      if block.previous_hash != last.hash
        # raise BlockHashMismatch.new "Hash mismatch for block at index #{block.index}"
        raise BlockOnForkChain.new
      end

      if block.difficulty != next_difficulty
        raise BlockNotAdded.new "Wrong difficulty block: #{block.difficulty} our: #{next_difficulty}"
      end

      if block.timestamp <= last.timestamp
        raise BlockNotAdded.new "Block time is wrong #{block.index}"
      end

      if last.difficulty != block.difficulty
        puts "Difficulty #{last.difficulty} -> #{block.difficulty}"
      end

      puts "#{block.mined_by_us? ? "Mined" : "Added"} #{block}"
      @blocks << block
      emit :block, block
    end
  end
end
