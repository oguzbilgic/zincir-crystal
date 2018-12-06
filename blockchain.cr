require "./block.cr"

class Blockchain
  getter blocks

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

  def work!
    loop do
      next_block = Block.next self.last, "Transaction Data..."

      @blocks << next_block

      puts "Solved: #{next_block}"
    end
  end
end
