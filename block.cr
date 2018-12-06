require "openssl"

class Block
  property index : Int32
  property timestamp : Int64
  property data : String
  property previous_hash : String
  property nonce : Int32, hash : String

  def initialize(@index, @timestamp, @data, @previous_hash)
    @nonce = solve_block
    @hash = calculate_hash @nonce
  end

  def initialize(@index, @timestamp, @data, @previous_hash, @nonce, @hash)
    verify!
  end

  def self.first
    Block.new 0, 0_i64, "Genesis", "0"
  end

  def self.next(previous : Block, data)
    Block.new previous.index + 1, Time.now.to_unix, data, previous.hash
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
    raise "invalid" if @hash != calculate_hash @nonce
  end

  def solve_block(difficulty = "00000", nonce = 0)
    loop do
      hash = calculate_hash nonce

      return nonce if hash.starts_with? difficulty

      nonce += 1
    end
  end

  def calculate_hash(nonce)
    hash = OpenSSL::Digest.new "SHA256"
    hash.update nonce.to_s + @index.to_s + @timestamp.to_s + @data + @previous_hash
    hash.hexdigest
  end
end
