require "./difficulty"

module Zincir
  class Blockchain
    include Difficulty

    BLOCK_DURATION = 10.0
    UPDATE_FREQUENCY = 10

    def initialize
      @blocks = [Block.first]
      @queued_blocks = [] of Block
      @callbacks = [] of Block -> Void
    end

    def last
      @blocks.last
    end

    def block_at(index)
      @blocks[index]
    end

    # TODO clean up
    def next_difficulty
      return last.difficulty if last.index == (UPDATE_FREQUENCY - 1)

      return last.difficulty if (last.index+1) % UPDATE_FREQUENCY > 0

      first_block = block_at last.index - 9
      duration =  last.timestamp - first_block.timestamp
      desired_duration = (BLOCK_DURATION * (UPDATE_FREQUENCY - 1))

      # TODO figure out how to use functions inside modules withouth the module name
      calculate_difficulty last.difficulty, duration, desired_duration
    end

    def on_block(&block : Block -> Void)
      @callbacks << block
    end

    def queue_block(block)
      @queued_blocks << block
      process_queued
    end

    def process_queued
      loop do
        return if @queued_blocks.empty?

        @queued_blocks.sort_by! {|b| b.index }

        next_block = @queued_blocks.shift

        if next_block.index < last.index + 1
          our_block = block_at next_block.index

          if our_block.timestamp > next_block.timestamp
            puts "Picking relayed #{next_block}"
            @blocks = @blocks[0..next_block.index]
            @blocks << next_block

            @callbacks.each { |callback| callback.call(next_block) }
          elsif our_block.hash == next_block.hash
            puts "Same #{next_block}"
          else
            puts "Picking ours #{next_block}"
          end
        elsif  next_block.index == last.index + 1
          next_block.verify!

          if next_block.previous_hash != last.hash
            raise "previous_hash for relayed block at index #{next_block.index}"
          end

          if next_block.timestamp <= last.timestamp
            next
            puts "Block time is wrong #{next_block.index}"
          end

          if next_block.difficulty != next_difficulty
            raise "Difficulty mismatch #{next_block.difficulty} #{next_difficulty}"
          end

          puts "Solved #{next_block}" if next_block.solved
          puts "Received #{next_block}" if !next_block.solved

          @blocks << next_block

          @callbacks.each { |callback| callback.call(next_block) }
        else
          @queued_blocks << next_block
          return
          # raise "Missing download? #{next_block}"
        end
      end
    end
  end
end
