# Лабораторная 2

## Описание
Сравнил плохой и хороший Dockerfile, а также плохой и хороший Docker Compose.

## Dockerfile 

### Плохой Dockerfile:
- Использует latest и копирует все подряд
- Добавляет лишнее, не заботится о безопасности
```dockerfile
# BAD Dockerfile
FROM golang:latest

WORKDIR /app

# Плохая практика: apt команды разбиты по слоям
RUN apt-get update
RUN apt-get install -y curl

# Плохая практика: ADD и копирование всего контекста
ADD . /app

# Плохая практика: сборка в одном этапе (без multi-stage)
RUN go build -o app ./cmd/app

EXPOSE 8080
# Плохая практика: строковая форма CMD и запуск под root
CMD go run ./cmd/app
```


### Хороший Dockerfile:
- Multi-stage билд, минимальный размер, USER, только нужные файлы
```dockerfile
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

```


## Docker Compose 

### Плохой вариант:
- Одна общая сеть, ping db работает
```dockerfile
# BAD docker-compose.yml
services:
  web:
    build: .
    image: webapp:latest
    ports:
      - "8080:8080"
  db:
    image: postgres:latest
    environment: 
      - POSTGRES_PASSWORD=postgres
    ports:
      - "5432:5432"
# по умолчанию одна сеть, оба сервиса "видят" друг друга по именам

```
 
### Хороший вариант:
- Разные сети, web не видит db
```dockerfile
# GOOD docker-compose.yml
services:
  web:
    build: .
    image: webapp:1.0
    ports:
      - "8080:8080"
    networks:
      - front_net

  db:
    image: postgres:16
    ports:
      - "5432:5432"
    networks:
      - back_net

networks:
  front_net:
    driver: bridge
  back_net:
    driver: bridge

```

---

## Итог
Best practices реально уменьшают размер, повышают безопасность и упрощают поддержку.


