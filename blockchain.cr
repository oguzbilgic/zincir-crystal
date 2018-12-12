require "./block.cr"

class Blockchain
  def initialize
    @blocks = [Block.first]
    @relayed_blocks = [] of Block
    @callbacks = [] of Block -> Void
  end

  def last
    @blocks.last
  end

  def block_at(index)
    @blocks[index]
  end

  def add_relayed_block(block)
    @relayed_blocks << block
    process_relayed
  end

  def process_relayed
    loop do
      return if @relayed_blocks.empty?

      @relayed_blocks.sort_by! {|b| b.index }

      next_block = @relayed_blocks.shift

      if next_block.index < last.index + 1
        our_block = block_at next_block.index

        if our_block.timestamp > next_block.timestamp
          puts "Picking relayed #{next_block}"
          @blocks = @blocks[0..next_block.index]
          @blocks << next_block
        elsif our_block.hash == next_block.hash
          puts "Same #{next_block}"
        else
          puts "Picking ours #{next_block}"
        end
      elsif  next_block.index == last.index + 1
        puts "Solved #{next_block}" if next_block.solved
        puts "Received #{next_block}" if !next_block.solved

        next_block.verify!

        if next_block.previous_hash != last.hash
          raise "previous_hash for relayed block at index #{next_block.index}"
        end

        @blocks << next_block
      else
        raise "Missing download? #{next_block}"
      end
    end
  end

  def work!
    loop do
      block = Block.next self.last, "Transaction Data..."

      next if block.previous_hash != last.hash

      @relayed_blocks << block
      process_relayed

      @callbacks.each { |callback| callback.call(block) }
    end
  end

  def on_solve(&block : Block -> Void)
    @callbacks << block
  end
end
