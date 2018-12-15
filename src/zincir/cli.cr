require "option_parser"

require "./cli/*"

module Zincir
  module Cli
    extend self

    def run!(args : Array(String))
      options = Options.new

      OptionParser.parse args do |parser|
        parser.banner = "Usage: zincir [arguments]"

        parser.on("-s IP", "--seed-ip=IP", "Specify ip for the seed node") { |i| options.seed_ip = i }
        parser.on("-i IP", "--host-ip=IP", "Specify ip for the host node") { |i| options.host_ip = i }
        parser.on("-p=PORT", "--port=PORT", "Start public server for other nodes to connect") { |i| options.port = i.to_i }
        parser.on("-w", "--web", "Start public server for other nodes to connect") { |i| options.public = true }
        # parser.on("-d DIR", "--dir=DIR", "Overide default cache directory") { |i| options.dir = i }
        parser.on("-m", "--mine", "Enable mining") { options.mine = true }

        parser.on("-h", "--help", "Show this help") do
          puts parser
          exit
        end

        parser.on("-v", "--version", "Show version") do
          puts "Zincir v#{VERSION}-crystal"
          exit 0
        end
      end

      run! options
    end

    def run!(options : Options)
      blockchain = Blockchain.new
      network = Network.new options.seed_ip

      # Read from file system
      Storage::File.load_and_sync blockchain

      # Sync with network
      Storage::Network.load_and_sync blockchain, network

      # Start web server if public
      spawn Web.start! network, blockchain, options.port, options.host_ip if options.public?

      # Start miner if mining
      spawn Miner.start! blockchain if options.mine?

      sleep
    end
  end
end
