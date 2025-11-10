# syntax=docker/dockerfile:1

# --- Builder stage: только нужные пакеты, фиксированная версия
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY cmd ./cmd
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/app ./cmd/app

# --- Runtime stage: маленький образ только для запуска
FROM alpine:3.21
RUN addgroup -S app && adduser -S app -G app
USER app
WORKDIR /app
COPY --from=builder /out/app ./app

EXPOSE 8080
ENTRYPOINT ["./app"]
