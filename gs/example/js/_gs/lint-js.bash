#!/usr/bin/env bash
docker run --rm \
	--user $(id -u):$(id -g) \
	-v "$(pwd)":/app \
	-w /app \
	node:lts-alpine \
	sh -c "npx standard --fix"
