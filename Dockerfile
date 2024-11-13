# syntax=docker.io/docker/dockerfile:1.7-labs

FROM golang:1.22.8 as cli
COPY  --exclude=ui . /go/src/github.com/keel-hq/keel
WORKDIR /go/src/github.com/keel-hq/keel
RUN make build

FROM node:22-alpine as ui
WORKDIR /app

# Setup yarn
COPY ui/.yarn/releases /app/.yarn/releases
COPY ui/package.json ui/yarn.lock ui/.yarnrc.yml /app
RUN yarn install

# Copy the rest of the app
COPY ui /app
RUN yarn run lint --no-fix
RUN NODE_OPTIONS=--openssl-legacy-provider yarn run build

FROM alpine:3.20.3
RUN apk --no-cache add ca-certificates

VOLUME /data
ENV XDG_DATA_HOME=/data

COPY --from=cli /go/src/github.com/keel-hq/keel/cmd/keel/keel /bin/keel
COPY --from=ui /app/dist /www
ENTRYPOINT ["/bin/keel"]
EXPOSE 9300
