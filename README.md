# HiveOS ZIL Autoswitcher

This is a shell script you can use to switch between mining your primary algo and a ZIL flightsheet just before the ZIL mining window starts. This can be useful in cases where the +ZIL configuration has lower hashrate than then same config without ZIL (for example NEXA).

## Install

You can use it by cloning the repo and setting up a service in your preffered distro or you can use the provided Docker image:

```shell
$ docker run -d -e "HIVEOS_API_URL=$url" \
  -e "HIVEOS_AUTH_TOKEN=token" \
  -e "PRIMARY_AND_ZIL_FS=number" \
  -e "PRIMARY_FS=number" \
  ghcr.io/karamoshi-nakatoto/hiveos-zil-autoswitcher:latest
```

Or the provided `docker-compose.yml` file:

```shell
$ docker-compose up
```

For explanation about the required environment variables, check out `.env.schema`
