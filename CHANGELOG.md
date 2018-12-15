# next

## Protocol

- [ ] Add `/nodes` endpoint for node discovery

## Implementation

- [ ] Add CLI options for 'seed node', 'mining', 'public_ip'
- [ ] Start web server only if the node has a public ip
- [ ] Save know node ips to file system for future use
- [ ] Add `Core` module for `Block`, `Blockchain` and `Difficulty`
- [ ] Add `Network` for `Network`, `Node`, `Web`

# v0.2

## Protocol

- Adjust difficulty using bits
- Use websocket for broadcasting solved blocks
- Remove `/connect` and `/relay` endpoints

## Implementation

- Store blockchain in `.block/` folder
- Add `Cli`, `Difficulty`, `Emitter`, `Miner`, `Node`, `Storage`, `Web` modules
- Use proper shard folder structure

# v0.1

Initial zincir implementation in Crystal
