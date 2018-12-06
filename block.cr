require "openssl"

class Block
  property hash : String
  getter index
  getter hash

  def initialize(@index : Int32, @timestamp : Int64, @data : String, @previous_hash : String)
    @nonce = solve_block
    @hash = calculate_hash @nonce
  end

  def initialize(@index : Int32, @timestamp : Int64, @data : String, @previous_hash : String, @nonce : Int32, @hash : String)
    verify!
  end

  def self.first
    Block.new 0, 0, "Genesis", "0"
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
