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
  - (скриншот/код good)

### Сравнение:
- ![docker-image-ls-app.png](screens/docker-image-ls-app.png)

---

## Docker Compose (со звездочкой)

### Плохой вариант:
- Одна общая сеть, ping db работает
  - (скрин bad compose, ping)

### Хороший вариант:
- Разные сети, web не видит db
  - (скрин good compose, ping error)

---

## Итог
Best practices реально уменьшают размер, повышают безопасность и упрощают поддержку.

---

## Скриншоты
- Всё тут: [screens/](screens)
