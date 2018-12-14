module Zincir
  module Difficulty
    extend self

    def satisfies?(hash, difficulty)
      hash_difficulty = hash[0..difficulty.size].to_i64(16)
      hash_difficulty <= (difficulty+ "f").to_i64(16)
    end

    # TODO
    def multiply_hex(hex, decimal)
      if decimal >= 16
        return "0" + hex
      end

      if decimal < 1
        still = decimal * 16
        return multiply_hex hex[1..-1], still
      end

      if hex.ends_with? '0'
        diff = 16 / decimal
        return hex + diff.to_i.to_s(16)
      end

      count = hex.count('0')
      # f_added = hex + "0"
      size = hex.to_i(16).to_s.size
      int_hex = hex.to_i(16)
      int_hex = hex.to_i(16) * 16 if size == 2
      int_hex = hex.to_i(16) * 16 * 16 if size == 1
      diff = int_hex.not_nil! / decimal

      if hex[-1].to_i(16) < decimal
        result = ("0" * count) + "0" + diff.to_i.to_s(16)
      else
        result = ("0" * count) + diff.to_i.to_s(16)
      end

      while result.ends_with? '0'
        result = result[0..-2]
      end
      result
    end

    # TODO figure out a sound way to calculate difficulty
    def calculate_difficulty(difficulty, duration, desired_duration)
      ratio = desired_duration / duration

      multiply_hex difficulty, ratio
    end
  end
end
