require "./block.cr"

class Miner
  def initialize(@blockchain : Blockchain)
  end

  def run!
    loop do
      next_difficulty = @blockchain.next_difficulty
      puts "Difficulty #{@blockchain.last.difficulty} -> #{next_difficulty}" if next_difficulty != @blockchain.last.difficulty
      
      block = Block.next @blockchain.last, next_difficulty, "Transaction Data..."

      next if block.previous_hash != @blockchain.last.hash

      next if block.timestamp <= @blockchain.last.timestamp

      @blockchain.queue_block block

      sleep 1
    end
  end
end
