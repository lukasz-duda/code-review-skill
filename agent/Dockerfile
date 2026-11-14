FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    glab \
    git \
    curl \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://gh.io/copilot-install | bash

COPY code_review.sh /usr/local/bin/code_review.sh

RUN useradd --create-home agent
USER agent

COPY .agents /home/agent/.agents

WORKDIR /home/agent
ENTRYPOINT ["code_review.sh"]