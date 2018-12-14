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

    def add_block(block)
      block.verify!

      if block.previous_hash != last.hash
        raise "previous_hash for relayed block at index #{block.index}"
      end

      if block.difficulty != next_difficulty
        raise "Difficulty mismatch #{block.difficulty} #{next_difficulty}"
      end

      if block.timestamp <= last.timestamp
        raise "Block time is wrong #{block.index}"
      end

      if last.difficulty != block.difficulty
        puts "Difficulty #{last.difficulty} -> #{block.difficulty}"
      end

      puts "#{block.mined_by_us? ? "Mined" : "Added"} #{block}"

      @blocks << block

      @callbacks.each { |callback| callback.call block }
    end

    def process_queued
      loop do
        return if @queued_blocks.empty?

        @queued_blocks.sort_by! {|b| b.index }

        block = @queued_blocks.shift

        if block.index < last.index + 1
          # if block has a lower index
          our_block = block_at block.index

          if our_block.timestamp > block.timestamp
            puts "Picking relayed #{block}"
            @blocks = @blocks[0..block.index]
            add_block block
          elsif our_block.hash == block.hash
            puts "Same #{block}"
          else
            puts "Picking ours #{block}"
          end
        elsif block.index == last.index + 1
          # if block has the current index
          add_block block
        else
          # if block has higher index
          @queued_blocks << block
          return
        end
      end
    end
  end
end
