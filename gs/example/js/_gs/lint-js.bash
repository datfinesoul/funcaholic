#!/usr/bin/env bash
docker run --rm \
	-v "$(pwd)":/app:ro \
	-w /app \
	--entrypoint '' \
	node:lts-alpine \
	sh -c "npx --yes standard --fix"
