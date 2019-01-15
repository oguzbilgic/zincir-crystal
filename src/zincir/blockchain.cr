require "colorize"
require "uuid"
require "uuid/json"
require "./difficulty"
require "./block"

module Zincir
  class Blockchain
    class BlockNotAdded < ::Exception; end

    # Desired time between blocks
    BLOCK_DURATION = 60.0
    # Number of blocks between difficulty adjustments
    UPDATE_FREQUENCY = 60

    property verbose = false

    include Emitter(Block -> Void)

    private class Chain
      property parent : Chain? = nil
      property branches = [] of UUID

      JSON.mapping(
        branches: {type: ::Array(UUID), setter: false},
        block: {type: Block, setter: false},
      )

      def initialize(@block : Block, @parent = nil, new_branch? = false)
        @branches = @parent.not_nil!.branches.dup if @parent

        @branches << UUID.random if new_branch?
      end

      def >(chain)
        @block > chain.block
      end
    end

    # Creates a blockchain with the first block
    def initialize
      @orphans = [] of Block
      @genesis = Chain.new Block.first, new_branch?: true
      @chains_by_hash = {@genesis.block.hash => @genesis} of String => Chain
      @chains_by_index = {0 => [@genesis]}
      @tips = [@genesis]
    end

    # Returns the index of the expected `Block`
    def next_index
      last.index + 1
    end

    # Returns the last `Block` in the blockchain
    def last
      @tips.max.not_nil!.block
    end

    # TODO: This shouldn't be exposed, currently for debugging purposes
    def tips
      @tips
    end

    # Returns the `Block` at *index*
    #
    # NOTE: This finds the correct block comparing the branch property of
    # the tip block and the blocks at the given index. There might be a
    # easier way to find the block
    def block_at(index)
      chains = @chains_by_index[index].map do |chain|
        highest_chain = @tips.max
        intersection = (chain.branches & highest_chain.branches)
        difference = (highest_chain.branches + chain.branches - intersection).uniq
        count = intersection.size - difference.size

        {chain: chain, count: count}
      end

      chains.sort_by(&.["count"]).last["chain"].block
    end

    def blocks_at(indexes : Enumerable(Int32))
      indexes = indexes.select do |index|
        index <= last.index
      end

      indexes.map do |index|
        block_at index
      end
    end

    # Returns the required difficulty for the next `Block`
    def next_difficulty
      next_difficulty_at last
    end

    # Returns the required difficulty for the next `Block`
    private def next_difficulty_at(block)
      return block.difficulty if block.index == UPDATE_FREQUENCY - 1

      return block.difficulty if (block.index + 1) % UPDATE_FREQUENCY > 0

      first = block_at block.index - UPDATE_FREQUENCY + 1
      duration = block.timestamp - first.timestamp
      desired_duration = (BLOCK_DURATION * (UPDATE_FREQUENCY - 1))

      Difficulty.calculate block.difficulty, duration, desired_duration
    end

    private def check_orphans(parent : Block)
      orphans = @orphans.select do |orphan|
        orphan.previous_hash == parent.hash
      end

      orphans.each do |orphan|
        puts "Adding orphan #{orphan}"
        @orphans.delete orphan
        queue_block orphan
      end
    end

    def queue_block(block : Block)
      # Check if the block is already in the chain
      if @chains_by_hash[block.hash]?
        puts "Block is already in the chain #{block}"
        return
      end

      unless block.valid?
        raise BlockNotAdded.new "Invalid block at index #{block.index}"
      end

      parent = @chains_by_hash[block.previous_hash]?

      # Check if the block is orphan
      unless parent
        puts "Orphan #{block}"
        @orphans << block
        return
      end

      if parent.block.index + 1 != block.index
        raise BlockNotAdded.new "Index is wrong #{block}"
      end

      if parent.block.timestamp > block.timestamp
        raise BlockNotAdded.new "Time is wrong #{block}"
      end

      if block.difficulty != next_difficulty_at parent.block
        raise BlockNotAdded.new "Difficulty is wrong #{block}"
      end

      if @tips.includes? parent
        chain = Chain.new block, parent
        @tips.delete parent
      else
        chain = Chain.new block, parent, true
      end

      @chains_by_hash[chain.block.hash] = chain
      if @chains_by_index[block.index]?
        @chains_by_index[block.index] << chain
      else
        @chains_by_index[block.index] = [chain]
      end

      @tips << chain
      print("\r") unless @verbose
      if block.mined_by_us?
        print "Mined".colorize(:green).to_s + " #{block}"
      else
        print "Added".colorize(:blue).to_s + " #{block}"
      end
      print("\n") if @verbose

      emit :block, block
      check_orphans block
    end
  end
end
