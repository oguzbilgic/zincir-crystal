module Zincir
  # TODO figure out how to use functions inside modules withouth the module name
  extend self

  # TODO clean up
  def flip_hex(hex)
    new_hex = ""
    hex.each_char do |char|
      new_hex += ('f'.to_i(16) - char.to_i(16)).to_s(16)
    end
    new_hex
  end

  # TODO clean up
  def multiply_hex(hex, decimal)
    # puts hex
    flipped_hex = flip_hex hex
    # puts flipped_hex
    decimal_hex = flipped_hex.to_i64(16)
    # puts decimal_hex
    sum = decimal_hex * decimal
    # puts sum

    x = 0
    result = 0
    loop do
      result = 16 ** (x+1)
      break if result > sum
      # puts x
      x += 1
    end
    # puts x

    additional = ((sum * 1.6) / result).to_i.to_s(16)
    # puts additional

    ("0" * x) + additional
  end

  # TODO clean up
  def calculate_difficulty(difficulty, duration, desired_duration)
    ratio = desired_duration / duration
    puts ratio

    if ratio > 1
      multiply_hex difficulty, ratio
    elsif ratio < 1
      multiply_hex difficulty, 1/ratio
    else
      difficulty
    end
  end
end

class Zincir::Blockchain
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
    Zincir.calculate_difficulty last.difficulty, duration, desired_duration
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
