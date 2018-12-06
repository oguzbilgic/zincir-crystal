require "./block.cr"

block = Block.first

loop do
  puts "Solved #{block.hash} at #{block.index}"
  block = Block.next(block, "new data")
end
