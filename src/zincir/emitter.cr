module Zincir
  module Emitter(T)
    def on(event, &hook : T)
      @callbacks ||= {} of Symbol => Array(T)
      @callbacks.not_nil![event] ||= [] of T
      @callbacks.not_nil![event] << hook
    end

    def emit(event, block)
      @callbacks.try(&.[event]).try &.each do |callback|
        callback.call block
      end
    end
  end
end
