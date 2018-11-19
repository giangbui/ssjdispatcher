FROM golang:1.10-alpine as build

# Install SSL certificates
RUN apk update && apk add --no-cache git ca-certificates gcc musl-dev

# Build static arborist binary
RUN mkdir -p /go/src/github.com/uc-cdis/ssjdispatcher
WORKDIR /go/src/github.com/uc-cdis/ssjdispatcher
ADD . .
RUN go build -ldflags "-linkmode external -extldflags -static" -o bin/ssjdispatcher

# Set up small scratch image, and copy necessary things over
FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/src/github.com/uc-cdis/ssjdispatcher/bin/ssjdispatcher /ssjdispatcher

ENTRYPOINT ["/ssjdispatcher"]