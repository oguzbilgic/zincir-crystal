require "colorize"
require "./difficulty"
require "./block"

module Zincir
  abstract class Blockchain
    class BlockNotAdded < ::Exception
    end

    class BlockIndexTooHigh < BlockNotAdded
    end

    class BlockNotPreferred < BlockNotAdded
    end

    class BlockOnForkChain < BlockNotAdded
    end

    # Desired time between blocks
    BLOCK_DURATION = 60.0
    # Number of blocks between difficulty adjustments
    UPDATE_FREQUENCY = 60

    include Emitter(Block -> Void)

    # Returns the last `Block` in the blockchain
    abstract def last

    # Returns the `Block` at *index*
    abstract def block_at(index)

    # Queues the *block* to be added to the blockchain
    abstract def queue_block(block)

    def blocks_at(indexes : Enumerable(Int32))
      indexes = indexes.select do |index|
        index <= last.index
      end

      indexes.map do |index|
        block_at index
      end
    end

    # Returns the required difficulty for the next `Block`
    def next_difficulty
      next_difficulty_at last
    end

    # Returns the index of the expected `Block`
    def next_index
      last.index + 1
    end

    # Returns the required difficulty for the next `Block`
    private def next_difficulty_at(block)
      return block.difficulty if block.index == UPDATE_FREQUENCY - 1

      return block.difficulty if (block.index + 1) % UPDATE_FREQUENCY > 0

      first = block_at block.index - UPDATE_FREQUENCY + 1
      duration = block.timestamp - first.timestamp
      desired_duration = (BLOCK_DURATION * (UPDATE_FREQUENCY - 1))

      Difficulty.calculate block.difficulty, duration, desired_duration
    end

    private def block_added(block)
      if block.mined_by_us?
        puts "Mined".colorize(:green).to_s + " #{block}"
      else
        puts "Added".colorize(:blue).to_s + " #{block}"
      end

      emit :block, block
    end
  end
end
