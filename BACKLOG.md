# backlog

## Protocol

- Add `/info` endpoint that returns node info such as client version or blockchain
  information

## Node

- Don't die/exit if the seed node is not reachable
- Prune old branches in blockchain when it's synced with the network
- When pruning the blockchain remove their corresponding block files
- Save know node ips to file system for future use
- Keep a list of offline ips and try to connect them periodically
- Use `~/.zincir` folder for configuration and blockchain cache
- Add CLI option to override `~/.zincir` directory

## Code

- Add `Core` module for `Block`, `Blockchain` and `Difficulty`
- Add `Network` module for `Network`, `Node`, `Web`
