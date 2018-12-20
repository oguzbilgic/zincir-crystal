require "option_parser"

module Zincir
  module Cli
    class Options
      property seed_ip = Network::TESTNET_SEED_HOST
      property host_ip : String? = nil
      property port : Int32? = nil
      property? mine = false
      property? web = false
      property? local = false
    end

    def self.run!(args : Array(String))
      options = Options.new

      OptionParser.parse args do |parser|
        parser.banner = "Usage: zincir [arguments]"

        parser.on("-s IP", "--seed-ip=IP", "First node to connect, TestNet by default") { |i| options.seed_ip = i }
        parser.on("-i IP", "--host-ip=IP", "Node's public ip, If the node is public") { |i| options.host_ip = i }
        parser.on("-p PORT", "--port=PORT", "Node's public port, If the node is public") { |i| options.port = i.to_i }
        parser.on("-l", "--local-net", "Prevents node from connecting to public nodes") { |i| options.local = true }
        parser.on("-w", "--web", "Start web server without making the node public") { |i| options.web = true }
        parser.on("-m", "--mine", "Enable mining") { options.mine = true }

        parser.on("-h", "--help", "Show this help") do
          puts parser
          exit
        end

        parser.on("-v", "--version", "Show node version") do
          puts "zincir-crystal v#{VERSION}"
          exit 0
        end
      end

      run! options
    end

    def self.run!(options : Options)
      blockchain = Blockchain::Tree.new

      seed_ip = options.local? ? nil : options.seed_ip
      network = Network.new seed_ip

      # Read from file system
      Storage::File.load_and_sync blockchain

      # Sync with network
      Storage::Network.load_and_sync blockchain, network

      # Start web server if enabled
      if options.web? || options.port || options.host_ip
        spawn Web.start! network, blockchain, options.port, options.host_ip
      end

      # Start miner if mining
      spawn Miner.start! blockchain if options.mine?

      sleep
    end
  end
end
