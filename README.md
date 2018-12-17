# Zincir 

Simple distributed blockchain experiment written in [Crystal](https://crystal-lang.org)

## Usage

### Install shards

```bash
$ shards install
$ shards build
  Dependencies are satisfied
  Building: zincir
  Building: zincird
$ ./bin/zincird --help
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

### Start a private node

```bash
$ ./bin/zincird --mine
  Connecting to testnet.zincir.xyz:9147
  Added <1-0878bff02..ec7> 1544946023
  ...
```

### Start a public node

```bash
$ ./bin/zincird --ip mynode.mywebsite.com --port 1234 --mine
  Connecting to testnet.zincir.xyz:9147
  Added <1-0878bff02..ec7> 1544946023
  ...
```
