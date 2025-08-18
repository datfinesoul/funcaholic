#!/usr/bin/env bash
docker run --rm \
	--user $(id -u):$(id -g) \
	-v "$(pwd)":/app \
	-w /app \
	python:3-slim \
	sh -c "pip install ruff && ruff check --fix ."
