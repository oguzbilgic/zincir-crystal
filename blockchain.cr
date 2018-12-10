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

  def work!
    loop do
      next_block = Block.next self.last, "Transaction Data..."

      @blocks << next_block

      puts "Solved: #{next_block}"
    end
  end
end
