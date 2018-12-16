# backlog

- [ ] BUG: Remove disconnected nodes from the Network
- [ ] Add CLI option to override blocks directory
- [ ] Add `-d` `--daemon` CLI option
- [ ] Log to a file if It's started as a daemon
- [ ] Save know node ips to file system for future use
- [ ] Add `Core` module for `Block`, `Blockchain` and `Difficulty`
- [ ] Add `Network` for `Network`, `Node`, `Web`
- [ ] Use `~/.zincir` folder for configuration and blockchain cache

# next

## Protocol

- Adjust difficulty every 60 blocks
- Much more accurate difficulty calculation
- Change websocket messages to have different types. Currently Block or IP information
  can be sent through the socket.
- Add `/nodes` endpoint that returns the known nodes' ips

## Node

- Connect to `Network::TESTNET_SEED_HOST` by default
- Explore the network continuously for new public nodes and connect
- Traverse blockchain backwards from the seed node if there is a hash mismatch
- Delete the block file if it's not added to the blockchain
- Broadcast our block to the network if the received block is not preferred
- Add CLI options
  * `--seed-ip=IP`
  * `--host-ip=IP`
  * `--port=PORT`
  * `--local-net`
  * `--mine`
  * `--web`
  * `--version`
  * `--help`

## Code

- Add `Blockchain::Exception`, `CLI::Options` modules

# v0.2

## Protocol

- Add `/blocks` websocket endpoint
- Remove `/connect` and `/relay` endpoints
- Adjust difficulty using bits

## Node

- Store blockchain in `.block/` folder
- Use websocket for broadcasting solved blocks

## Code

- Add `Cli`, `Difficulty`, `Emitter`, `Miner`, `Node`, `Storage`, `Web` modules
- Use proper shard folder structure

# v0.1

Initial zincir implementation in Crystal
