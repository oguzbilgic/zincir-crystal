require "./block.cr"

BLOCK_DURATION = 10.0
UPDATE_FREQUENCY = 10

# TODO clean up
def flip_hex(hex)
  new_hex = ""
  hex.each_char do |char|
    new_hex += ('f'.to_i(16) - char.to_i(16)).to_s(16)
  end
  new_hex
end

# TODO clean up
def add_decimal(hex, decimal)
  # puts hex
  flipped_hex = flip_hex hex
  # puts flipped_hex
  decimal_hex = flipped_hex.to_i64(16)
  # puts decimal_hex
  sum = decimal_hex + decimal
  # puts sum
  hex_sum = sum.to_s(16)
  # puts hex_sum
  flipped_sum = flip_hex hex_sum
  # puts flipped_sum

  if flipped_sum.size > hex.size
    # puts "OVERFLOW #{decimal} #{16-decimal}"
    return add_decimal hex+"0", decimal-16
  elsif flipped_sum.size < hex.size
    # remove fs
  end

  if flipped_sum.to_i64(16) != 0 && flipped_sum.ends_with? "0"
    return "0" + flipped_sum.rchop '0'
  end

  flipped_sum
end

class Blockchain
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
    ratio = (BLOCK_DURATION * (UPDATE_FREQUENCY - 1)) / duration

    if ratio > 2
      add_decimal last.difficulty, 16
    elsif ratio > 1
      add_decimal last.difficulty, ((16 * ratio) - 16).to_i
    elsif ratio < 1
      add_decimal last.difficulty, (-16 * (1-ratio)).to_i
    else
      last.difficulty
    end
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
