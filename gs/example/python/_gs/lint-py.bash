#!/usr/bin/env bash
docker run --rm \
	-v "$(pwd)":/app:ro \
	-w /app \
	--entrypoint '' \
	python:3-slim \
	sh -c "pip install ruff && ruff check --fix ."
