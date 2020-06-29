.PHONY: build run

IMAGE   := instoll/orca
USER_ID := `id -u $$USER`

build:
	docker build -t $(IMAGE) .

run:
	docker run --rm -e HOST_USER_ID=$(USER_ID) $(IMAGE) bash -c "tail -f /dev/null"

