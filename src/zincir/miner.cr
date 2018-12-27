module Zincir
  module Miner
    # Starts mining the blockchain
    def self.start!(blockchain)
      puts "Starting block miner..."
      new_block_channel = Channel(Bool).new

      blockchain.on :block do |block|
        new_block_channel.send true
      end

      index_changed = false
      spawn do
        loop do
          index_changed = new_block_channel.receive
        end
      end

      loop do
        last_block = blockchain.last
        difficulty = blockchain.next_difficulty
        index = blockchain.next_index.to_s
        # puts "Mining ".colorize(:magenta).to_s + index
        data = "Transaction Data... #{Random.rand 100}"
        timestamp = Time.now.to_unix.to_s
        nonce = -1

        index_changed = false
        loop do
          nonce += 1
          hash = Block.calculate_hash nonce.to_s, index, timestamp, data, last_block.hash

          break if Difficulty.satisfies? hash, difficulty

          break if index_changed
          Fiber.yield
        end

        next if index_changed

        block = Block.new index.to_i, timestamp.to_i64, data, last_block.hash, difficulty, nonce

        blockchain.queue_block block
      end
    end
  end
end
