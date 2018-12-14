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

      last_num = hex[-1].to_i(16)
      if last_num == 0
          diff = 16.0 / decimal
          hex + diff.round(0).to_i.to_s(16)
      elsif last_num >= decimal.to_i
        diff = last_num.to_f / decimal
        hex[0..-2] + diff.round(0).to_i.to_s(16)
      else
        still = decimal / last_num.to_f
        multiply_hex hex[0..-2] + '0', still.to_f
      end
    end

    # TODO figure out a sound way to calculate difficulty
    def calculate_difficulty(difficulty, duration, desired_duration)
      ratio = desired_duration / duration

      multiply_hex difficulty, ratio
    end
  end
end
