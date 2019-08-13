build:
	./hack/build.sh

serve:
	./hack/serve.sh

clean:
	./hack/clean.sh

diff: clean
	./hack/diff.sh