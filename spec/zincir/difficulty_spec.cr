require "./../spec_helper"

describe Zincir::Difficulty do
  describe "#multiply_hex" do
    it "correctly multiplies hex string with the decimal" do
      Zincir::Difficulty.multiply_hex("000", 2).should eq("0008")
      Zincir::Difficulty.multiply_hex("000", 4).should eq("0004")
      Zincir::Difficulty.multiply_hex("000", 10).should eq("0002")
      Zincir::Difficulty.multiply_hex("000", 16).should eq("0000")
      Zincir::Difficulty.multiply_hex("0001", 1).should eq("0001")
      Zincir::Difficulty.multiply_hex("0002", 2).should eq("0001")
      Zincir::Difficulty.multiply_hex("0004", 2).should eq("0002")
      Zincir::Difficulty.multiply_hex("0008", 8).should eq("0001")
      Zincir::Difficulty.multiply_hex("0004", 8).should eq("00008")
      Zincir::Difficulty.multiply_hex("00002", 3).should eq("00000b")

      Zincir::Difficulty.multiply_hex("001", 0.25).should eq("004")
      Zincir::Difficulty.multiply_hex("00e", 0.5).should eq("02")
      Zincir::Difficulty.multiply_hex("004", 0.5).should eq("008")
      Zincir::Difficulty.multiply_hex("000", 0.25).should eq("004")
      Zincir::Difficulty.multiply_hex("0002", 0.5).should eq("0004")
      Zincir::Difficulty.multiply_hex("0002", 0.25).should eq("0008")
    end
  end
end
