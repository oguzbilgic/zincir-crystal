require "openssl"
require "json"
require "http/client"
require "kemal"

require "./zincir/emitter"
require "./zincir/*"
require "./zincir/blockchain/*"
require "./zincir/storage/*"

module Zincir
  VERSION = "0.7.1"
end
