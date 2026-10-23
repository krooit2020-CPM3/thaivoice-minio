FROM golang:1.24.8-bookworm AS builder
WORKDIR /src

RUN git clone --depth 1 --branch RELEASE.2025-08-13T08-35-41Z https://github.com/minio/mc.git .
RUN test "$(git rev-parse HEAD)" = "7394ce0dd2a80935aded936b09fa12cbb3cb8096"

ENV CGO_ENABLED=0
RUN go mod download
RUN go build -buildvcs=false -trimpath -o /out/mc .

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /out/mc /usr/local/bin/mc
COPY --from=builder /src/LICENSE /usr/share/licenses/mc/LICENSE

CMD ["mc", "--version"]
