# backlog

## Protocol

- Add `/info` endpoint that returns node info such as client version or blockchain
  information

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
