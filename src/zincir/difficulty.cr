module Zincir
  module Difficulty
    # Number of non zero characters at the end of the difficulty
    #
    # ````
    # "000000f" # precision 1
    # "004f0" # precision 3
    # "0014f0" # precision 4
    # "14f000" # precision 6
    # ````
    PRECISION = 4

    # Returs true if the given *hash* satisfies the given *difficulty*
    def self.satisfies?(hash, difficulty)
      hash_difficulty = hash[0..difficulty.size-1].to_i64(16)
      hash_difficulty <= difficulty.to_i64(16)
    end

    # Returns the adjusted difficulty for the given *duration* and *desired_duration*
    def self.calculate(current_difficulty : String, duration, desired_duration)
      ratio = desired_duration / duration

      if ratio > 1.1 || ratio < 0.9
        multiply current_difficulty, ratio
      else
        current_difficulty
      end
    end

    # Returns true if the given `String` is a valid *difficulty*
    #
    # TODO: Implement
    def self.valid?(difficulty)
    end

    def self.multiply(difficulty, multiplier)
      zero_count = 0
      difficulty.chars.each do |char|
        break unless char == '0'
        zero_count += 1
      end

      decimal = hex_to_dec difficulty
      product = decimal / multiplier

      while product > (16 ** PRECISION)
        product /= 16
        zero_count -= 1
      end

      hex_product = dec_to_hex product.to_i

      ("0" * zero_count) + hex_product
    end

    # Converts hext to decimal ignoring leading 0s
    # Adds trailing f as necessary to match the precision
    def self.hex_to_dec(hex)
      while hex.starts_with? "0"
        hex = hex[1..-1]
      end

      while hex.size > PRECISION
        hex = hex[0..-2]
      end

      while hex.size < PRECISION
        hex = hex + "f"
      end

      hex.to_i 16
    end

    def self.dec_to_hex(dec)
      while dec > (16 ** PRECISION)
        dec /= 16
      end

      hex = dec.to_s 16

      while hex.size < PRECISION
        hex = '0' + hex
      end

      hex
    end
  end
end
