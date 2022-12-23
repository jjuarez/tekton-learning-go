# syntax=docker/dockerfile:1.4
FROM golang:1.19-alpine3.17 AS builder
WORKDIR /build
COPY go.mod ./
RUN go mod download 
COPY . ./
RUN go build -v -o dist/cmd ./...


FROM scratch AS runtime
WORKDIR /app
COPY --from=builder /build/dist/cmd /app/cmd
ENTRYPOINT [ "/app/cmd" ]
