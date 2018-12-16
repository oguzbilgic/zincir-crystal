# backlog

## Implementation

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

- Much more accurate difficulty calculation
- Change websocket messages to have different types. Currently Block or IP information
  can be sent through the socket.
- Add `/nodes` endpoint that returns the known nodes' ips

## Node

- Traverse chain backwards from the seed node if there is a hash mismatch
- Delete the block file if it's not added to the blockchain
- Broadcast our block to the network if the received block is not preferred
- Use `Network::TESTNET_SEED_HOST` as the default seed host
- Add `--seed-ip=IP`, `--host-ip=IP`, --web`, `--port=PORT`, `--mine`, `-v`, `-h`, `-l` CLI options
  * Start miner only if it's enabled via `--mine`
  * Start web server only if it's enabled via `--web` or if `--port=PORT` is specified

## Code

- Add `Blockchain::Exception` module

# v0.2

## Protocol

- Adjust difficulty using bits
- Use websocket for broadcasting solved blocks
- Remove `/connect` and `/relay` endpoints

## Node

- Store blockchain in `.block/` folder

## Code

- Add `Cli`, `Difficulty`, `Emitter`, `Miner`, `Node`, `Storage`, `Web` modules
- Use proper shard folder structure

# v0.1

Initial zincir implementation in Crystal
