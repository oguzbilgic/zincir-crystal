require "benchmark"
require "../../src/zincir"

Benchmark.ips do |x|
  genesis = Zincir::Block.first
  
  # x.report("Block.next f") {
  #   Zincir::Block.next genesis, "f", "Data #{rand}"
  # }

  x.report("Block.next 0") {
    Zincir::Block.next genesis, "0", "Data #{rand}"
  }

  x.report("Block.next 00") {
    Zincir::Block.next genesis, "00", "Data #{rand}"
  }

  x.report("Block.next 000") {
    Zincir::Block.next genesis, "000", "Data #{rand}"
  }

  x.report("Block.next 0000") {
    Zincir::Block.next genesis, "0000", "Data #{rand}"
  }
end
