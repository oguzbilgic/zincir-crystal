require "./difficulty"

module Zincir
  class Blockchain
    BLOCK_DURATION = 60.0
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

    def next_index
      last.index + 1
    end

    # TODO clean up
    def next_difficulty
      return last.difficulty if last.index < 3

      if last.index < UPDATE_FREQUENCY * 3
        first = block_at last.index-2
        duration =  last.timestamp - first.timestamp
        desired_duration = BLOCK_DURATION * (last.index - first.index)

        # TODO figure out how to use functions inside modules withouth the module name
        return Difficulty.calculate_difficulty last.difficulty, duration, desired_duration
      end

      return last.difficulty if next_index % UPDATE_FREQUENCY > 0

      first = block_at last.index - UPDATE_FREQUENCY + 1
      duration =  last.timestamp - first.timestamp
      desired_duration = (BLOCK_DURATION * (UPDATE_FREQUENCY - 1))

      # TODO figure out how to use functions inside modules withouth the module name
      Difficulty.calculate_difficulty last.difficulty, duration, desired_duration
    end

    def on_block(&block : Block -> Void)
      @callbacks << block
    end

    def queue_block(block)
      @queued_blocks << block

      process_queued
    end

    private def add_block(block)
      unless block.valid?
        raise "Invalid block #{block.index}"
      end

      if block.previous_hash != last.hash
        raise "Hash mismatch for block at index #{block.index}"
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

    private def process_queued
      loop do
        return if @queued_blocks.empty?

        @queued_blocks.sort_by! {|b| b.index }

        return if next_index < @queued_blocks.first.index

        block = @queued_blocks.shift

        # if block has a lower index
        if next_index > block.index
          our_block = block_at block.index

          return if our_block.hash == block.hash

          return if our_block.timestamp <= block.timestamp

          puts "Reseting chain with #{block}"
          @blocks = @blocks[0..block.index]
        end

        add_block block
      end
    end
  end
end
