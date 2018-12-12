require "./block.cr"

class Blockchain
  def initialize
    @blocks = [Block.first]
    @relayed_blocks = [] of Block
  end

  def last
    @blocks.last
  end

  def block_at(index)
    @blocks[index]
  end

  def add_relayed_block(block)
    @relayed_blocks << block
  end

  def process_relayed
    loop do
      return if @relayed_blocks.empty?

      @relayed_blocks.sort_by! {|b| b.index }

      next_block = @relayed_blocks.shift

      if next_block.index < last.index + 1
        puts "Discarding relayed block for index " + next_block.index.to_s
      elsif  next_block.index == last.index + 1
        puts "Adding relayed block at index " + next_block.index.to_s

        next_block.verify!

        if next_block.previous_hash != last.hash
          raise "previous_hash doesn't match with the relayed block at index " + next_block.index.to_s
        end

        @blocks << next_block
      else
        raise "Missing download? " + next_block.index.to_s
      end
    end
  end

  def work!
    loop do
      process_relayed

      next_block = Block.next self.last, "Transaction Data..."

      next unless @relayed_blocks.empty?

      @blocks << next_block

      puts "Solved: #{next_block}"
    end
  end
end
