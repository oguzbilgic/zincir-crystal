require "kemal"
require "http/client"

require "./blockchain.cr"

port = Random.rand(1000) + 4000
blockchain = Blockchain.new
nodes = ARGV.empty? ? [] of String : [ARGV.first]

post "/relay" do |env|
  block = Block.from_json env.request.body.not_nil!
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
if !nodes.empty?
  node = nodes.first

  form = "ip=http://localhost:#{port}"
  connect = HTTP::Client.post "#{node}/connect", form: form
  puts "Connected seed server: #{node}"

  last_index = blockchain.last.index

  loop do
    last_index += 1
    response = HTTP::Client.get "#{node}/blocks/#{last_index}"

    break if response.status_code != 200

    block = Block.from_json response.body
    blockchain.add_relayed_block block
    puts "Downloaded #{block}"
  end

  puts "Finished downloading the chain"
end

blockchain.on_solve do |block|
  nodes.each do |node|
    connect = HTTP::Client.post "#{node}/relay", form: block.to_json
  end
end

spawn do
  blockchain.work!
end

sleep
