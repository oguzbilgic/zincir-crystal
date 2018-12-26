require "uuid"
require "uuid/json"

module Zincir
  class Blockchain::Tree < Blockchain
    private class Chain
      property parent : Chain? = nil

      JSON.mapping(
        branches: {type: ::Array(UUID), setter: false},
        block: {type: Block, setter: false},
      )

      def initialize(@block : Block, @branches)
      end

      def >(chain)
        @block > chain.block
      end
    end

    # Creates a blockchain with the first block
    def initialize
      @orphans = [] of Block
      @genesis = Chain.new Block.first, [UUID.random]
      @chains_by_hash = {@genesis.block.hash => @genesis} of String => Chain
      @chains_by_index = {0 => [@genesis]}
      @tips = [@genesis]
    end

    # Returns the last `Block` in the blockchain
    def last
      highest_chain.not_nil!.block
    end

    # Returns the `Block` at *index*
    #
    # NOTE: This finds the correct block comparing the branch property of
    # the tip block and the blocks at the given index. There might be a 
    # easier way to find the block
    def block_at(index)
      chains = @chains_by_index[index].map do |chain|
        intersection = (chain.branches & highest_chain.branches)
        difference = (highest_chain.branches + chain.branches - intersection).uniq
        count = intersection.size-difference.size

        {chain: chain, count: count}
      end

      chains.sort_by(&.["count"]).last["chain"].block
    end

    # Queues the *block* to be added to the blockchain
    def queue_block(block : Block)
      return if @chains_by_hash[block.hash]?

      add_chain block
    end

    private def highest_chain
      @tips.max
    end

    def tips
      @tips
    end

    private def check_orphans(parent : Block)
      orphans = @orphans.select do |orphan|
        orphan.previous_hash == parent.hash
      end

      orphans.each do |orphan|
        @orphans.delete orphan
        add_chain orphan
      end
    end

    private def add_chain(block : Block)
      unless block.valid?
        raise BlockNotAdded.new "Invalid block at index #{block.index}"
      end

      parent = @chains_by_hash[block.previous_hash]?

      if parent
        if !parent.parent && parent != @genesis
          puts "Orphan Parent #{block}"
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
          chain = Chain.new block, parent.branches
          chain.parent = parent
          @tips.delete parent
        else
          chain = Chain.new block, parent.branches + [UUID.random]
          chain.parent = parent
        end

        @tips << chain
        block_added block

        check_orphans block

        @chains_by_hash[chain.block.hash] = chain
        if @chains_by_index[block.index]?
          @chains_by_index[block.index] << chain
        else
          @chains_by_index[block.index] = [chain]
        end
      else
        puts "Orphan #{block}"
        @orphans << block
      end
    end
  end
end
