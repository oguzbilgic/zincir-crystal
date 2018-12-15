module Zincir
  module Cli
    class Options
      property seed_ip : String? = nil
      getter host_ip : String? = nil
      property? public = false
      getter port : Int32? = nil
      property? mine = false

      # property dir = "~/.zincir"

      def host_ip=(@host_ip)
        @public = true if host_ip
      end

      def port=(@port)
        @public = true if port
      end
    end
  end
end
