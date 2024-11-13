FROM golang:1.22.8
COPY . /go/src/github.com/keel-hq/keel
WORKDIR /go/src/github.com/keel-hq/keel
RUN make build

FROM node:16.20.2-alpine
WORKDIR /app
COPY ui /app
RUN yarn
RUN yarn run lint --no-fix
RUN yarn run build

FROM alpine:3.20.3
RUN apk --no-cache add ca-certificates

VOLUME /data
ENV XDG_DATA_HOME=/data

COPY --from=0 /go/src/github.com/keel-hq/keel/cmd/keel/keel /bin/keel
COPY --from=1 /app/dist /www
ENTRYPOINT ["/bin/keel"]
EXPOSE 9300
