# require 'json'
require "digest"

class Block
  # attr_reader :index, :timestamp, :data, :previous_hash, :nonce, :hash

  def initialize(@index : Int32, @timestamp : Int32, @data : String, @previous_hash : String, nonce : Int32 = nil, hash : String = nil)
    unless nonce && hash
      @nonce, @hash = solve_block
    else
      @nonce = nonce
      @hash = hash
      verify!
    end
  end

  def self.first
    Block.new 0, 0, "Genesis", "0", 0, ""
  end

  def self.next(previous, data)
    Block.new previous.index + 1, Time.now.to_i, data, previous.hash
  end

  def self.from_json_str(str)
    block_hash = JSON.parse(str)

    Block.new block_hash["index"].to_i, block_hash["timestamp"], block_hash["data"], block_hash["previous_hash"], block_hash["nonce"].to_i, block_hash["hash"]
  end

  def to_hash
    { index: index, timestamp: timestamp, data: data, previous_hash: previous_hash, nonce: nonce, hash: hash }
  end

  def to_s
    "#{@hash} #{@index}"
  end

  def verify!
    calculated_hash = calculate_hash @nonce

    raise "invalid" if calculated_hash != @hash
  end

  def solve_block(difficulty="00000")
    nonce = 0
    loop do
      hash = calculate_hash nonce
      if hash.start_with? difficulty
        return [nonce,hash]
      else
        nonce += 1
      end
    end
  end

  def calculate_hash(nonce = 0)
    Digest::SHA1.hexdigest nonce.to_s + @index.to_s + @timestamp.to_s + @data + @previous_hash
  end
end

block = Block.first
