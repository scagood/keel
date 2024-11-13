FROM alpine:3
RUN apk --no-cache add ca-certificates

VOLUME /data
ENV XDG_DATA_HOME=/data

COPY ./cmd/keel/release/keel-$TARGETOS-$TARGETARCH /bin/keel
COPY ./ui/dist /www
ENTRYPOINT ["/bin/keel"]
EXPOSE 9300
