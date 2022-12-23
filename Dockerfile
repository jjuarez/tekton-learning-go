# syntax=docker/dockerfile:1.4
FROM golang:1.19-alpine3.17 AS builder
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download 
COPY . ./
RUN go build -v -o dist/cmd ./...


FROM alpine:3.17 AS runtime
WORKDIR /app
COPY --from=builder /build/dist/cmd /app/cmd
EXPOSE 8080/tcp
CMD [ "/app/cmd" ]
