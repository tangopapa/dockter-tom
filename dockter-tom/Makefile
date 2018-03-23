all: help

build:
	@echo "Building docker container.."
	@./build-dockter-tom.sh

clean:
	@echo "Removing unused docker containers..."
	@./docker-clean.sh

clean-all: clean
	@echo "Removing dockter-tom image..."
	@docker rmi dockter-tom

interactive:
	@docker run --rm -it --entrypoint /bin/bash dockter-tom

help:
	@echo "the help menu"
	@echo "  make build"
	@echo "  make clean"
	@echo "  make clean-all"
	@echo "  make help"
	@echo "  make install-stub"
	@echo "  make interactive"

.PHONY: build clean
