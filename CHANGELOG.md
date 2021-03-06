# v0.8.0

## Code

- Merge `Blockchain::Tree` into `Blockchain`
- Remove `Blockchain::Array`

# v0.7.1

## Node

- Fix a bug in which a node with --local option, wasn't broadcasting the 
  mined blocks
- Don't log blockchain when reading from the network or filesystem

## Code 

- Add `Blockchain#verbose` property

# v0.7.0

## Node

- Make `/blocks/` endpoint handle index range and array
- Download 1000 blocks at a time when syncing with the network

## Code

- Add `{Blockchain, Network, Node}#blocks_at`

# v0.6.0

## Code
- Add `Blockchain::Tree` implementation replacing the array implementation

# v0.5.0

## Node

- Relay network blocks If they haven't been seen before
- Fix bugs in `Storage::File` and `Storage::Network`
- Update CLI options' descriptions

## Code

- Add `Storage::Network.check_sync_status`
- Add `Storage::Network.find_mutual_block`

# v0.4.1

## Node

- Fix hex overflow bug in Difficulty.multiply which resulted in higher
  difficulty while It was trying to reduce the difficulty
- Fix Storage::Network bug which caused broadcasting existing block

## Code

- Add experimental `bench/` directory for benchmarking

# v0.4.0

## Node

- Broadcast blocks to network if the local blockchain has higher index
- Remove the node from the network when it is closed
- Fix a bug which caused some validations to be skipped if the chain is being reseted
- Improve miner so that as soon as a new block is added by network, It moves on
  to the next index.

## Code

- Add `Block.calculate_hash`, `{Network, Node}#last_block`
- Rename `{Network, Node}#download_block` to `{Network, Node}#block_at`

# v0.3.1

## Node

- Fix critical blockchain bug which prevented resetting the chain
- Make miner skip the mined block if another block is already added to chain with the
  same index
- Use different colors for logs

# v0.3

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

- Add `Blockchain::BlockNotAdded` exceptions
- Add `CLI::Options` modules
- Add initial documentation

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
