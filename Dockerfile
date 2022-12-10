FROM golang:1.19-alpine as builder
RUN apk --no-cache add ca-certificates build-base git
WORKDIR /yo
COPY . .
RUN go mod download && go mod verify
RUN go test -v ./...
#RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main
RUN make build

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
ENV PORT 8080
COPY --from=builder /yo/advent ./advent
CMD ["./advent"]
