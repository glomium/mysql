BASEIMAGE=ubuntu:rolling

build:
	docker build --build-arg BASEIMAGE=$(BASEIMAGE) .

buildx:
	# docker buildx build --progress plain --platform linux/amd64,linux/arm64,linux/arm/v7 --build-arg BASEIMAGE=$(BASEIMAGE) --push -t glomium/mysql:multiarch .
	docker buildx build --progress plain --platform linux/amd64 --build-arg BASEIMAGE=$(BASEIMAGE) --push -t glomium/mysql:multiarch .
