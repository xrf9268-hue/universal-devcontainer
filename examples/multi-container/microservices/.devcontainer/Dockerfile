FROM mcr.microsoft.com/devcontainers/typescript-node:4-24-bookworm@sha256:2baba848f88e02278bcf59e072752f7371534ccfc67afcd8e0ee6b293865c6f9

# Install Python
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y python3 python3-pip python3-venv \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz \
    && rm go1.21.0.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

# Install common tools
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    jq \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
