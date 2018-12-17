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

        # This can be removed when miner is able stop mining the block
        # when it's already added to the chain by another miner
        next if block.index != blockchain.next_index

        blockchain.queue_block block
      rescue Blockchain::BlockNotAdded
      end
    end
  end
end
