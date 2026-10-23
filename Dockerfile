FROM golang:1.24.8-bookworm AS builder
WORKDIR /src

RUN git clone --depth 1 --branch RELEASE.2025-10-15T17-29-55Z https://github.com/minio/minio.git .
RUN test "$(git rev-parse HEAD)" = "9e49d5e7a648f00e26f2246f4dc28e6b07f8c84a"

ENV CGO_ENABLED=0
RUN go mod download
RUN go build -buildvcs=false -trimpath -o /out/minio .

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /out/minio /usr/local/bin/minio
COPY --from=builder /src/LICENSE /usr/share/licenses/minio/LICENSE
RUN mkdir -p /data

EXPOSE 9000 9001
CMD ["minio", "server", "/data", "--console-address", ":9001"]
