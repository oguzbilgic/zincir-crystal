module Zincir
  module Difficulty
    extend self

    def hash_to_bits(hash)
      bits = [] of Array(Int32)

      hash.each_char do |char|
        i = char.to_i(16)
        byte = (0..3).map { |n| i.bit(n) }
        bits << byte.reverse
      end

      bits.flat_map { |c| c }
    end

    def satisfies?(hash, difficulty : Int)
      size = (difficulty/4) + 1
      bits = hash_to_bits hash[0..size]

      bits[0..difficulty - 1].join("") == "0" * difficulty
    end

    def calculate_difficulty(difficulty : Int, duration, desired_duration)
      ratio = desired_duration / duration

      if ratio > 1.5
        difficulty + 1
      elsif ratio < 0.5
        difficulty - 1
      else
        difficulty
      end
    end

    def satisfies?(hash, difficulty : String)
      hash_difficulty = hash[0..difficulty.size].to_i64(16)
      hash_difficulty <= (difficulty + "f").to_i64(16)
    end

    # TODO find a way to convert decimal difficulty to hex, reverse of this function
    def hex_to_dec(hex)
      nums = [] of Float64
      hex.each_char do |char|
        nums << (16.0 / (char.to_i(16) + 1))
      end

      return nums.reduce { |a, b| a * b }
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
    def calculate_difficulty(difficulty : String, duration, desired_duration)
      ratio = desired_duration / duration

      multiply_hex difficulty, ratio
    end
  end
end
