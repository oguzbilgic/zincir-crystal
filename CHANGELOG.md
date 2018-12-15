# backlog

## Protocol

- [ ] Add `/nodes` endpoint for node discovery

## Implementation

- [ ] Add CLI option to override blocks directory
- [ ] Save know node ips to file system for future use
- [ ] Add `Core` module for `Block`, `Blockchain` and `Difficulty`
- [ ] Add `Network` for `Network`, `Node`, `Web`

# next

## Implementation

- Add `--seed-ip=IP`, `--web`, `--port=PORT`, `--mine`, `-v` and `-h` CLI options
  * Start miner only if it's enabled via `--mine`
  * Start web server only if it's enabled via `--web` or if `--port=PORT` is specified

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
