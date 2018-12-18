# Zincir

Simple distributed blockchain experiment written in [Crystal](https://crystal-lang.org)

 - [Documents](http://docs.zincir.xyz)
 - [Releases](https://github.com/oguzbilgic/zincir-crystal/releases)
 - [Network Explorer](http://explorer.zincir.xyz)

## Usage

### Build

To build zincir, you will need [Crystal](https://crystal-lang.org/) and
[OpenSSL](https://www.openssl.org/) installed on your system. You can use
[Homebrew](https://brew.sh/) on Mac to install these dependencies.

```bash
> git clone git@github.com:oguzbilgic/zincir-crystal.git
  ...
> shards install
  ...
> shards build --release
  Dependencies are satisfied
  Building: zincird
```

### Usage

```shell
> ./bin/zincird --help
  Usage: zincir [arguments]
      -s IP, --seed-ip=IP              Specify ip for the seed node
      -i IP, --host-ip=IP              Specify ip for the host node
      -p PORT, --port=PORT             Start public server for other nodes to connect
      -l, --local-net                  Prevents initial seed node connections
      -w, --web                        Enable web server
      -m, --mine                       Enable mining
      -h, --help                       Show this help
      -v, --version                    Show version
```

### Start

```bash
> ./bin/zincird --mine
  Connecting to testnet.zincir.xyz:9147
  Added <1-0878bff02..ec7> 1544946023
  ...
```

Node will connect to `TestNet` by default and sync the blockchain, before mining.
Blockchain will be cached in `./blocks/` folder.

### Start a public node

```bash
> ./bin/zincird --ip mynode.mywebsite.com --port 1234 --mine
  Connecting to testnet.zincir.xyz:9147
  Added <1-0878bff02..ec7> 1544946023
  ...
```

In public mode, node will advertise it's ip and host to the network for other
nodes to connect. Therefore, node needs to be publicly accessible with the
provided ip and port configuration

## Development

### Run tests

```bash
$ crystal spec
  ...
```
