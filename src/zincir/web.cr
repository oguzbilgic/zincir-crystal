module Zincir
  def start_web!(port, network, blockchain)
    get "/blocks" do
      blockchain.last.to_json
    end

    get "/blocks/:index" do |env|
      index = env.params.url["index"].to_i

      blockchain.block_at(index).to_json
    end

    ws "/blocks" do |socket, env|
      network.add_node env.request.host_with_port.not_nil!, socket
    end

    puts "Starting web server at port #{port}"
    logging false
    Kemal.run port
  end
end
