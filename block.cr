require "openssl"
require "json"

class Block
  property solved = false

  JSON.mapping(
    index: Int32,
    timestamp: Int64,
    data: String,
    previous_hash: String,
    difficulty: String,
    nonce: Int32,
    hash: String,
  )

  def initialize(@index, @timestamp, @data, @previous_hash, @difficulty)
    @solved = true
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
    io << "<#{index}-#{@hash[0..6]}..#{@hash[-5..-1]}>"
  end

  def verify!
    raise "invalid" if @hash != calculate_hash @nonce
  end

  def solve_block(difficulty = "00000", nonce = 0)
    loop do
      hash = calculate_hash nonce

      return {nonce, hash} if hash.starts_with? difficulty

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
