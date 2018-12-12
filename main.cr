require "kemal"
require "http/client"

require "./blockchain.cr"

port = Random.rand(1000) + 4000
blockchain = Blockchain.new

post "/relay" do |env|
  block = Block.from_json env.request.body.not_nil!
  puts "New block received for index " + block.index.to_s
  blockchain.add_relayed_block block
end

get "/blocks" do
  blockchain.last.to_json
end

get "/blocks/:index" do |env|
  index = env.params.url["index"].to_i

  blockchain.block_at(index).to_json
end

spawn do
  puts "Starting web server at port " + port.to_s
  logging false
  Kemal.run port
end

# See Connection & Initial Download
if !ARGV.empty?
  form = "ip=http://localhost:#{port}"
  connect = HTTP::Client.post ARGV.first + "/connect", form: form
  puts "Connected seed server " + ARGV.first

  last_index = blockchain.last.index

  loop do
    last_index += 1
    response = HTTP::Client.get ARGV.first + "/blocks/" + last_index.to_s

    break if response.status_code != 200

    puts "Downloaded block at index: " + last_index.to_s
    block = Block.from_json response.body
    blockchain.add_relayed_block block
  end

  puts "Finished downloading the chain"
end

spawn do
  blockchain.work!
end

sleep
