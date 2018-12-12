require "./block.cr"

class Miner
  def initialize(@blockchain : Blockchain)
  end

  def run!
    loop do
      block = Block.next @blockchain.last, "Transaction Data..."

      next if block.previous_hash != @blockchain.last.hash

      @blockchain.add_relayed_block block
    end
  end
end
