require "json"
require "./difficulty"

module Zincir
  class Block
    property? mined_by_us = false

    JSON.mapping(
      index: {type: Int32, setter: false},
      timestamp: {type: Int64, setter: false},
      data: {type: String, setter: false},
      previous_hash: {type: String, setter: false},
      difficulty: {type: String, setter: false},
      nonce: {type: Int32, setter: false},
      hash: {type: String, setter: false},
    )

    def initialize(@index, @timestamp, @data, @previous_hash, @difficulty)
      @mined_by_us = true
      # verify if the difficulty is valid
      @nonce, @hash = solve_block @difficulty
    end

    def self.first
      Block.new 0, 0_i64, "Genesis", "0", "0"
    end

    def self.next(previous, difficulty, data)
      Block.new previous.index + 1, Time.now.to_unix, data, previous.hash, difficulty
    end

    def to_s(io)
      io << "<#{index}-#{@hash[0..15]}..#{@hash[-3..-1]}@#{@timestamp}>"
    end

    def valid?
      @hash == calculate_hash @nonce
    end

    def solve_block(difficulty, nonce = 0)
      loop do
        hash = calculate_hash nonce

        return {nonce, hash} if Difficulty.satisfies? hash, difficulty

        nonce += 1
        Fiber.yield
      end
    end

    def calculate_hash(nonce)
      hash = OpenSSL::Digest.new "SHA256"
      hash.update nonce.to_s + @index.to_s + @timestamp.to_s + @data + @previous_hash
      hash.hexdigest
    end
  end
end
