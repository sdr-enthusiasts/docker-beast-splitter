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

## Testing the container

Once running, you can test the container to ensure it is correctly receiving data by issuing the command:

```shell
docker exec -it beast-splitter viewadsb
```

Which should display a departure-lounge-style screen showing all the aircraft being tracked, for example:

```
 Hex    Mode  Sqwk  Flight   Alt    Spd  Hdg    Lat      Long   RSSI  Msgs  Ti -
────────────────────────────────────────────────────────────────────────────────
 7C801C S                     8450  256  296                   -28.0    14  1
 7C8148 S                     3900                             -21.5    19  0
 7C7A48 S     1331  VOZ471   28050  468  063  -31.290  117.480 -26.8    48  0
 7C7A4D S     3273  VOZ694   13100  376  077                   -29.1    14  1
 7C7A6E S     4342  YGW       1625  109  175  -32.023  115.853  -5.9    71  0
 7C7A71 S           YGZ        725   64  167  -32.102  115.852 -27.1    26  0
 7C42D1 S                    32000  347  211                   -32.0     4  1
 7C42D5 S                    33000  421  081  -30.955  118.568 -28.7    15  0
 7C42D9 S     4245  NWK1643   1675  173  282  -32.043  115.961 -13.6    60  0
 7C431A S     3617  JTE981   24000  289  012                   -26.7    41  0
 7C1B2D S     3711  VOZ9242  11900  294  209  -31.691  116.118  -9.5    65  0
 7C5343 S           QQD      20000  236  055  -30.633  116.834 -25.5    27  0
 7C6C96 S     1347  JST116   24000  397  354  -30.916  115.873 -17.5    62  0
 7C6C99 S     3253  JST975    2650  210  046  -31.868  115.993  -2.5    70  0
 76CD03 S     1522  SIA214     grnd   0                        -22.5     7  0
 7C4513 S     4220  QJE1808   3925  282  279  -31.851  115.887  -1.9    35  0
 7C4530 S     4003  NYA      21925  229  200  -30.933  116.640 -19.8    58  0
 7C7533 S     3236  XFP       4300  224  266  -32.066  116.124  -6.9    74  0
 7C4D44 S     3730  PJQ      20050  231  199  -31.352  116.466 -20.1    62  0
 7C0559 S     3000  BCB       1000                             -18.4    28  0
 7C0DAA S     1200            2500  146  002  -32.315  115.918 -26.6    48  0
 7C6DD7 S     1025  QFA793   17800  339  199  -31.385  116.306  -8.7    53  0
 8A06F0 S     4131  AWQ544    6125  280  217  -32.182  116.143 -12.6    61  0
 7CF7C4 S           PHRX1A                                     -13.7     8  1
 7CF7C5 S           PHRX1B                                     -13.3     9  1
 7C77F6 S           QFA595     grnd 112  014                   -33.2     2  2
```

Press `CTRL-C` to escape this screen.

## Getting help

Please feel free to [open an issue on the project's GitHub](https://github.com/sdr-enthusiasts/docker-beast-splitter/issues).

Join our [Discord channel](https://discord.gg/sTf9uYF) and converse.

[1]: https://github.com/flightaware/beast-splitter
[2]: http://www.modesbeast.com/
