### Build keepalived-exporter
ARG GOVERSION=1.15

FROM golang:${GOVERSION}-alpine as builder
WORKDIR /build
RUN apk add --no-cache make git bash curl
RUN curl -sSL https://github.com/cafebazaar/keepalived-exporter/archive/refs/tags/v1.2.0.tar.gz | tar xz --strip-components=1
RUN make build


#### Runtime

FROM alpine:3.15

ENV \
  DISABLE_EXPORTER=false \
  EXPORTER_LISTEN_ADDRESS=":9165"

RUN apk add --no-cache \
    bash \
    curl \
    jq \
    iproute2 \
    keepalived

COPY --from=builder /build/keepalived-exporter .
COPY rootfs /

EXPOSE 9165

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["keepalived", "--log-console", "--dont-fork", "--use-file", "/etc/keepalived/keepalived.conf"]
