PROJECT := ceph-korean-doc
DOCKER_IMAGE := ceph-korean-doc-dockerenv
DOCKER_BUILDKIT := 0

all: build serve

build:
	./hack/build.sh

serve:
	./hack/serve.sh

check_docker:
	type docker > /dev/null

build_image:
	DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker build . -t $(DOCKER_IMAGE)

build_docker: build_image
	docker run --rm \
		-v `pwd`:/$(PROJECT)/ \
		--name $(PROJECT)-builder \
		 $(DOCKER_IMAGE) \
		bash -c "make build"

serve_docker: build_image
	docker run --rm \
		-v `pwd`:/$(PROJECT)/ \
		-p 8080:8080 \
		--name $(PROJECT)-server \
		 $(DOCKER_IMAGE) \
		bash -c "make serve"

clean:
	./hack/clean.sh

diff: clean
	./hack/diff.sh

querytrans: 
	./hack/querytrans.sh