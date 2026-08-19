# Stage 1: Build
FROM golang:1.26-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go mod tidy
RUN CGO_ENABLED=0 go build -o /bin/myapp-api ./cmd/api
RUN CGO_ENABLED=0 go build -o /bin/myapp-migrate ./cmd/migrate

# Stage 2: Runtime
FROM alpine:3.24
RUN apk add --no-cache ca-certificates \
    && adduser -D -H -s /sbin/nologin appuser
COPY --from=builder /bin/myapp-api /bin/myapp-api
COPY --from=builder /bin/myapp-migrate /bin/myapp-migrate
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD ["wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/livez"]
CMD ["/bin/myapp-api"]
