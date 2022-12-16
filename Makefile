APP?=advent
PROJECT?=example.com/api
PORT?=8000
RELEASE?=0.0.1
COMMIT?=$(shell git rev-parse --short HEAD)
BUILD_TIME?=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
GOOS?=linux
GOARCH?=amd64
CONTAINER_IMAGE?=${APP}

clean:
	rm -f ${APP}

build: clean
	CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build \
		-ldflags "-s -w -X ${PROJECT}/version.Release=${RELEASE} \
		-X ${PROJECT}/version.Commit=${COMMIT} -X ${PROJECT}/version.BuildTime=${BUILD_TIME}" \
		-o ${APP}

#run: build
#	PORT=${PORT} ./${APP}

test:
	go test -v -race ./...

# === Container
container: build
	docker build --no-cache -t ${APP}:${RELEASE} .

run: container
	docker stop $(APP):$(RELEASE) || true && docker rm $(APP):$(RELEASE) || true
	docker run --name ${APP} -p ${PORT}:${PORT} --rm \
		-e "PORT=${PORT}" \
		$(APP):$(RELEASE)

push: container
	minikube image load $(CONTAINER_IMAGE):$(RELEASE)

minikube: #push
	for t in ./kubernetes/advent/*.yml; do \
        cat $$t | \
        	sed -E "s/\{\{(\s*)\.Release(\s*)\}\}/$(RELEASE)/g" | \
        	sed -E "s/\{\{(\s*)\.ServiceName(\s*)\}\}/$(APP)/g"; \
        echo \\n---; \
    done > tmp.yaml
	kubectl apply -f tmp.yaml
	rm tmp.yaml