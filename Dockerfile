FROM golang:1.21 as builder

WORKDIR /workspace

COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download

COPY main.go main.go
COPY cmd/ cmd/
COPY pkg/ pkg/
COPY resources/ resources/
COPY dev/ dev/


RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o sysdig-aws-nuke main.go

FROM quay.io/sysdig/sysdig-mini-ubi9:1.2.0 as ubi
LABEL org.opencontainers.image.title "sysdig-aws-nuke"
LABEL org.opencontainers.image.authors "Sysdig <dev-ops@sysdig.com>"

USER sysdig
WORKDIR /home/sysdig
COPY --from=builder /workspace/sysdig-aws-nuke .

ENTRYPOINT ["/usr/local/bin/aws-nuke"]
