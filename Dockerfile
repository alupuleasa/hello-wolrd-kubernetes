#!/bin/bash
FROM alpine:latest
RUN apk update && apk add bash

COPY /server /server
WORKDIR /server

# ENTRYPOINT ["/bin/ash"]
ENTRYPOINT ["./server.sh"]