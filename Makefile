UBUNTU=rolling

build:
	docker build --build-arg UBUNTU=$(UBUNTU) .

buildx:
	docker buildx build --pull --progress plain --platform linux/amd64,linux/arm64,linux/arm/v7 --build-arg UBUNTU=$(UBUNTU) --push -t glomium/mysql:multiarch .
