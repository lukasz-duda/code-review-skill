FROM ubuntu:24.04

COPY --from=node:22-slim /usr/local /usr/local

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    glab \
    git \
    curl \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

ARG AGENT_UID=1000
ARG AGENT_GID=1000
RUN getent group "$AGENT_GID" >/dev/null || groupadd --gid "$AGENT_GID" agent \
    && existing_user="$(getent passwd "$AGENT_UID" | cut -d: -f1)" \
    && if [ -n "$existing_user" ]; then \
        usermod --groups '' --login agent --home /home/agent --move-home --gid "$AGENT_GID" "$existing_user"; \
    else \
        useradd --create-home --uid "$AGENT_UID" --gid "$AGENT_GID" agent; \
    fi

USER agent
ENV HOME="/home/agent"
ENV PATH="/home/agent/.pi/agent/bin:$PATH"

RUN curl -fsSL https://pi.dev/install.sh | sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY login.sh /usr/local/bin/login.sh