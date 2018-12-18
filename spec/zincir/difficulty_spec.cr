require "./../spec_helper"

describe Zincir::Difficulty do
  describe ".hex_to_dec" do
    cases = [
      {"0", 65535},
      {"5", 24575},

      {"f", 65535},
      {"ff", 65535},
      {"fff", 65535},
      {"ffff", 65535},
      {"0ffff", 65535},
      {"fffff", 65535},

      {"1", 8191},
      {"01", 8191},
      {"01f", 8191},
      {"01ff", 8191},
      {"01fff", 8191},
      {"01ffff", 8191},

      {"10", 4351},

    ]

    cases.each do |c|
      Zincir::Difficulty.hex_to_dec(c[0]).should eq(c[1])
    end
  end

  describe ".dec_to_hex" do
    cases = [
      {16*65535, "ffff"},
      {65535, "ffff"},
      {1, "0001"},
      {11111, "2b67"},
      {1234, "04d2"},
    ]

    cases.each do |c|
      Zincir::Difficulty.dec_to_hex(c[0]).should eq(c[1])
    end
  end

  describe ".multiply" do
    cases = [
      {"f", 2.0, "7fff"},
      {"ff", 2.0, "7fff"},
      {"fff", 2.0, "7fff"},
      {"ffff", 2.0, "7fff"},

      {"0f", 2.0, "07fff"},
      {"0ff", 2.0, "07fff"},
      {"0fff", 2.0, "07fff"},
      {"0ffff", 2.0, "07fff"},

      {"1", 1, "1fff"},
      {"f", 1, "ffff"},
      {"0", 1, "0ffff"},

      {"7", 2.0, "3fff"},
      {"10", 2.0, "087f"},

      {"10", 1.5, "0b54"},
      {"0005", 1.5, "0003fff"},
      {"0005", 1.1, "0005744"},
      {"0005", 1.01, "0005f0b"},

      {"0005", 0.5, "000bffe"},
      {"0005", 1, "0005fff"},
      {"0005", 8, "0000bff"},
      {"0005", 16, "00005ff"},
      {"0005", 16.0, "00005ff"},
      {"0005", 16.00, "00005ff"},
      {"0005", 16.000, "00005ff"},
      {"0005", 16.0000, "00005ff"},

      {"09", 0.6, "10aa"},
      {"000000908", 0.562351072279587, "000001010"},
    ]

    cases.each do |c|
      Zincir::Difficulty.multiply(c[0], c[1]).should eq(c[2])
    end
  end
end
