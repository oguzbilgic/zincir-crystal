module Zincir
  module Storage
    abstract class Base
      abstract def load_and_start
    end
  end
end
