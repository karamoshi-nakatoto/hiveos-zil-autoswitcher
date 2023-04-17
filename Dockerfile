# syntax=docker/dockerfile:1
FROM ghcr.io/kaykayehnn/dockerfiles/shell:main

WORKDIR /app

RUN apk add --no-cache curl

# Copy app files
COPY daemon.sh .

CMD [ "/app/daemon.sh" ]
