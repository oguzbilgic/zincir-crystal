module Zincir
  module Difficulty
    # TODO clean up
    def flip_hex(hex)
      new_hex = ""
      hex.each_char do |char|
        new_hex += ('f'.to_i(16) - char.to_i(16)).to_s(16)
      end
      new_hex
    end

    # TODO clean up
    def multiply_hex(hex, decimal)
      # puts hex
      flipped_hex = flip_hex hex
      # puts flipped_hex
      decimal_hex = flipped_hex.to_i64(16)
      # puts decimal_hex
      sum = decimal_hex * decimal
      # puts sum

      x = 0
      result = 0
      loop do
        result = 16 ** (x+1)
        break if result > sum
        # puts x
        x += 1
      end
      # puts x

      additional = ((sum * 1.6) / result).to_i.to_s(16)
      # puts additional

      ("0" * x) + additional
    end

    # TODO clean up
    def calculate_difficulty(difficulty, duration, desired_duration)
      ratio = desired_duration / duration
      # puts ratio

      if ratio > 1
        multiply_hex difficulty, ratio
      elsif ratio < 1
        multiply_hex difficulty, 1/ratio
      else
        difficulty
      end
    end
  end
end
