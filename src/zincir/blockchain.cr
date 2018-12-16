require "./difficulty"

module Zincir
  class Blockchain
    module Exception
      class BlockNotAdded < ::Exception end
      class BlockHashMismatch < BlockNotAdded end
      class BlockIndexTooHigh < BlockNotAdded end
      class BlockDifficultyError < BlockNotAdded end
      class BlockNotPreferred < BlockNotAdded end
      class BlockTimeError < BlockNotAdded end
      class InvalidBlock < BlockNotAdded end
    end

    BLOCK_DURATION   = 60.0
    UPDATE_FREQUENCY =   60

    include Emitter(Block -> Void)

    def initialize
      @blocks = [Block.first]
      @queued_blocks = [] of Block
    end

    def last
      @blocks.last
    end

    def block_at(index)
      @blocks[index]
    end

    def next_index
      last.index + 1
    end

    # TODO clean up
    def next_difficulty
      return last.difficulty if last.index == UPDATE_FREQUENCY - 1

      return last.difficulty if next_index % UPDATE_FREQUENCY > 0

      first = block_at last.index - UPDATE_FREQUENCY + 1
      duration = last.timestamp - first.timestamp
      desired_duration = (BLOCK_DURATION * (UPDATE_FREQUENCY - 1))

      Difficulty.calculate_difficulty last.difficulty, duration, desired_duration
    end

    def queue_block(block)
      @queued_blocks << block

      until @queued_blocks.empty?
        begin
          block = @queued_blocks.sort_by!(&.index).shift

          add_block block
        rescue Exception::BlockIndexTooHigh
          @queued_blocks << block
          break
        end
      end
    end

    private def add_block(block)
      unless block.valid?
        raise Exception::InvalidBlock.new "Invalid block at index #{block.index}"
      end

      if block.index > next_index
        raise Exception::BlockIndexTooHigh.new
      end

      if next_index > block.index
        our_block = block_at block.index

        return if our_block.hash == block.hash

        if our_block.timestamp <= block.timestamp
          raise Exception::BlockNotPreferred.new "Blockchain contains a better block for index #{block.index}"
        end

        puts "Reseting chain with #{block}"

        @blocks = @blocks[0..block.index]
        return
      end

      if block.previous_hash != last.hash
        raise Exception::BlockHashMismatch.new "Hash mismatch for block at index #{block.index}"
      end

      if block.difficulty != next_difficulty
        raise Exception::BlockDifficultyError.new "Wrong difficulty block: #{block.difficulty} our: #{next_difficulty}"
      end

      if block.timestamp <= last.timestamp
        raise Exception::BlockTimeError.new "Block time is wrong #{block.index}"
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
