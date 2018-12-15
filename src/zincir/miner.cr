module Zincir
  module Miner
    extend self

    def start!(blockchain)
      loop do
        next_difficulty = blockchain.next_difficulty

        data = "Transaction Data... #{Random.rand 100}"
        block = Block.next blockchain.last, next_difficulty, data

        next if block.previous_hash != blockchain.last.hash

        next if block.timestamp <= blockchain.last.timestamp

        blockchain.queue_block block

        sleep 1
      end
    end
  end
end
