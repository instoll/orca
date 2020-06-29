.PHONY: build run

IMAGE := instoll/orca

build:
	docker build -t $(IMAGE) .

run:
	docker run --rm $(IMAGE) bash -c "tail -f /dev/null"

