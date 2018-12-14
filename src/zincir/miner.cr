module Zincir
  class Miner
    def initialize(@blockchain : Blockchain)
    end

    def run!
      loop do
        next_difficulty = @blockchain.next_difficulty
        puts "Difficulty #{@blockchain.last.difficulty} -> #{next_difficulty}" if next_difficulty != @blockchain.last.difficulty

        data = "Transaction Data... #{Random.rand(5)}"
        block = Block.next @blockchain.last, next_difficulty, data

        next if block.previous_hash != @blockchain.last.hash

        next if block.timestamp <= @blockchain.last.timestamp

        @blockchain.queue_block block

        sleep 1
      end
    end
  end
end
