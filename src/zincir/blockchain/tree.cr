module Zincir
  class Blockchain::Tree < Blockchain
    private class Chain
      property parent : Chain? = nil
      getter block

      forward_missing_to @block

      def initialize(@block : Block)
      end
    end

    # Creates a blockchain with the first block
    def initialize
      @orphans = [] of Chain
      @genesis = Chain.new Block.first
      @chains = {@genesis.block.hash => @genesis} of String => Chain
      @tips = [@genesis]
    end

    # Returns the last `Block` in the blockchain
    def last
      heighest_chain.not_nil!.block
    end

    # Returns the `Block` at *index*
    def block_at(index)
      parent = heighest_chain

      loop do
        return parent.not_nil!.block if parent.not_nil!.index == index
        parent = parent.not_nil!.parent
      end
    end

    # Queues the *block* to be added to the blockchain
    def queue_block(block)
      return if @chains[block.hash]?

      add_chain Chain.new block
    end

    private def heighest_chain
      @tips.max
    end

    def tips
      @tips.map &.block
    end

    private def check_orphans(parent)
      orphans = @orphans.select do |orphan|
        orphan.previous_hash == parent.hash
      end

      @orphans = @orphans - [orphans]
      orphans.each do |orphan|
        add_chain orphan
      end
    end

    private def add_chain(chain)
      unless chain.valid?
        raise BlockNotAdded.new "Invalid block at index #{chain.index}"
      end

      parent = @chains[chain.previous_hash]?

      if parent
        if !parent.parent && parent.index != 0
          puts "Orphan Parent #{chain.block}"
          @orphans << chain
          return
        end

        if parent.index + 1 != chain.index
          raise BlockNotAdded.new "Index is wrong #{chain.block}"
        end

        if parent.timestamp > chain.timestamp
          raise BlockNotAdded.new "Time is wrong #{chain.block}"
        end

        if chain.difficulty != next_difficulty_at parent
          raise BlockNotAdded.new "Difficulty is wrong #{chain.block}"
        end

        chain.parent = parent
        if @tips.includes? parent
          @tips.delete parent
        end

        @tips << chain
        block_added chain.block

        check_orphans chain
      else
        puts "Orphan #{chain.block}"
        @orphans << chain
      end

      @chains[chain.block.hash] = chain
    end
  end
end
