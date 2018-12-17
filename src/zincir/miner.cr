module Zincir
  module Miner
    # Starts mining the blockchain
    #
    # TODO: If block is solved in the meantime move onto the next block immediately
    def self.start!(blockchain)
      loop do
        next_difficulty = blockchain.next_difficulty
        data = "Transaction Data... #{Random.rand 100}"
        block = Block.next blockchain.last, next_difficulty, data

        blockchain.queue_block block
      rescue Blockchain::BlockNotAdded
      end
    end
  end
end
