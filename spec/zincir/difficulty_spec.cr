require "./../spec_helper"

describe Zincir::Difficulty do
  describe "#multiply_hex" do
    it "correctly multiplies hex string with the decimal" do
      Zincir::Difficulty.multiply_hex("000", 2).should eq("0008")
      Zincir::Difficulty.multiply_hex("000", 4).should eq("0004")
      Zincir::Difficulty.multiply_hex("000", 10).should eq("0001")
      Zincir::Difficulty.multiply_hex("000", 16).should eq("0000")
      Zincir::Difficulty.multiply_hex("0001", 1).should eq("0001")
      Zincir::Difficulty.multiply_hex("0002", 2).should eq("0001")
      Zincir::Difficulty.multiply_hex("0004", 2).should eq("0002")
      Zincir::Difficulty.multiply_hex("0008", 8).should eq("0001")
      Zincir::Difficulty.multiply_hex("0004", 8).should eq("00008")
      Zincir::Difficulty.multiply_hex("00002", 3).should eq("00000aa")

      Zincir::Difficulty.multiply_hex("00003", 0.5).should eq("00006")
      Zincir::Difficulty.multiply_hex("00003", 0.9).should eq("000035")
      Zincir::Difficulty.multiply_hex("00003", 0.94).should eq("000033")
      Zincir::Difficulty.multiply_hex("00003", 0.95).should eq("000032")
      Zincir::Difficulty.multiply_hex("00003", 0.957).should eq("000032")
      Zincir::Difficulty.multiply_hex("00003", 0.97).should eq("000031")
      Zincir::Difficulty.multiply_hex("00003", 1.1).should eq("00002ba")
      Zincir::Difficulty.multiply_hex("00003", 1.123).should eq("00002ab")
      Zincir::Difficulty.multiply_hex("00003", 1.2).should eq("000028")
      Zincir::Difficulty.multiply_hex("00003", 1.3).should eq("000024e")

      Zincir::Difficulty.multiply_hex("0000404", 0.5).should eq("000008")
      Zincir::Difficulty.multiply_hex("0000aaa", 0.95).should eq("0000b3")
      Zincir::Difficulty.multiply_hex("0000aaa", 1).should eq("0000aaa")
      Zincir::Difficulty.multiply_hex("0000aaa", 1.03).should eq("0000a5a")
      Zincir::Difficulty.multiply_hex("0000aaa", 1.1).should eq("00009b1")
      Zincir::Difficulty.multiply_hex("0000aaa", 1.15).should eq("0000945")
      Zincir::Difficulty.multiply_hex("0000aaa", 1.18).should eq("0000909")

      # fix
      # Zincir::Difficulty.multiply_hex("0001c9", 2.8).should eq("0000a3")

      Zincir::Difficulty.multiply_hex("001", 0.25).should eq("004")
      Zincir::Difficulty.multiply_hex("00e", 0.5).should eq("01c")
      Zincir::Difficulty.multiply_hex("004", 0.5).should eq("008")
      Zincir::Difficulty.multiply_hex("000", 0.25).should eq("004")
      Zincir::Difficulty.multiply_hex("0002", 0.5).should eq("0004")
      Zincir::Difficulty.multiply_hex("0002", 0.25).should eq("0008")
    end
  end
end
