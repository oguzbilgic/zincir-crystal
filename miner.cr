require "./block.cr"

class Miner
  def initialize(@blockchain : Blockchain)
  end

  def run!
    loop do
      block = Block.next @blockchain.last, "Transaction Data..."

      next if block.previous_hash != @blockchain.last.hash

      next if block.timestamp <= @blockchain.last.timestamp

      @blockchain.queue_block block
      
      sleep 1
    end
  end
end
