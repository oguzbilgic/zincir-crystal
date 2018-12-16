module Zincir
  module Cli
    class Options
      property seed_ip = Network::TESTNET_SEED_HOST
      property host_ip : String? = nil
      property port : Int32? = nil
      property? mine = false
      property? web = false
    end
  end
end
