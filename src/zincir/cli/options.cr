module Zincir
  module Cli
    class Options
      property seed_ip : String? = nil
      property? public = false
      getter port : Int32? = nil
      property? mine = false

      # property dir = "~/.zincir"

      def port=(port)
        public = true if port
        @port = port
      end
    end
  end
end
