# sdr-enthusiasts/docker-beast-splitter

FlightAware's [beast-splitter][1] helper utility for the [Mode-S Beast][2], running in a docker container.

The Beast provides a single data stream over a (USB) serial port. If you have more than one thing that wants to read that data stream, you need something to redistribute the data. This is what beast-splitter does.

More information on [beast-splitter][1] is available at the [official repository][1].

## Environment Variables

| Variable | Controls which `beast-splitter` option | Description | Default |
| -------- | -------------------------------------- | ----------- | ------- |
| `BEAST_SPLITTER_SERIAL`  | `--serial`     | Read from given serial device                                  | `/dev/beast` |
| `BEAST_SPLITTER_NET`     | `--net`        | Read from given network host:port                              | Unset |
| `BEAST_SPLITTER_BAUD`    | `--fixed-baud` | Set a fixed baud rate, or 0 for autobauding                    | `0` |
| `BEAST_SPLITTER_LISTEN`  | `--listen`     | Specify a `[host:]port[:settings]` to listen on                | `0.0.0.0:30005:R` |
| `BEAST_SPLITTER_CONNECT` | `--connect`    | Specify a `host:port[:settings]` to connect to                 | Unset |
| `BEAST_SPLITTER_FORCE`   | `--force`      | Specify settings to force on or off when configuring the Beast | Unset |

## Example `docker run`

```bash
docker run \
  -d -it --restart=always \
  --name beast-splitter \
  --device /dev/beast:/dev/beast \
  -p 30005:30005 \
  ghcr.io/sdr-enthusiasts/docker-beast-splitter:latest
```

## Example `docker-compose.yml` service

```yaml
  beast-splitter:
    image: ghcr.io/sdr-enthusiasts/docker-beast-splitter:latest
    tty: true
    container_name: beast-splitter
    restart: always
    devices:
      - /dev/beast:/dev/beast
    ports:
      - 30005:30005
```

## Getting help

Please feel free to [open an issue on the project's GitHub](https://github.com/sdr-enthusiasts/docker-beast-splitter/issues).

Join our [Discord channel](https://discord.gg/sTf9uYF) and converse.



[1]: https://github.com/flightaware/beast-splitter
[2]: http://www.modesbeast.com/
