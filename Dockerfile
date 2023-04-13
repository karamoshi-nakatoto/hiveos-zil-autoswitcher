# syntax=docker/dockerfile:1
FROM alpine:3.17 AS build-env

# Add Tini
ENV TINI_VERSION v0.19.0
ENV TINI_RELEASE tini-muslc-amd64
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${TINI_RELEASE} /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${TINI_RELEASE}.asc /tini.asc
RUN apk add --no-cache gnupg \
  && gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
  && gpg --batch --verify /tini.asc /tini \
  && chmod +x /tini

WORKDIR /app

# Build runtime image
FROM alpine:3.17

# Setup Tini
COPY --from=build-env /tini /
ENTRYPOINT ["/tini", "--"]

WORKDIR /app
# Copy app files
COPY daemon.sh .

CMD [ "/app/daemon.sh" ]
