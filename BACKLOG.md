# backlog

## Protocol

- Bug: if the block has the same timestamp, each chain picks own block,
  which causes chains to be partitioned.
- Add `/info` endpoint that returns node info such as client version or blockchain
  information
- Add ability to request multiple blocks via `/blocks/` endpoint. Either with
  a range `/blocks/0..15` or an array `/blocks/3,78,12`

## Node

- If block is already received or in the queue disregard
- Save know node ips to file system for future use
- Keep a list of offline ips and try to connect them periodically
- Add `-d` `--daemon` CLI option
- Use `~/.zincir` folder for configuration and blockchain cache
- Add CLI option to override `~/.zincir` directory
- Log to a file if It's started as a daemon

## Code

- Add `Core` module for `Block`, `Blockchain` and `Difficulty`
- Add `Network` module for `Network`, `Node`, `Web`
