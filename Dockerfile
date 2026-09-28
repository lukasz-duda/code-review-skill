FROM ubuntu:24.04

COPY --from=node:22-slim /usr/local /usr/local

RUN apt-get update \
    && apt-get install -y --no-install-recommends glab curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://pi.dev/install.sh | sh

ENV PATH="/root/.pi/agent/bin:$PATH"