FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm@sha256:49698b6eae8a476ebfe37652b03a415d66f4e7ea8e1f8253a46b7a7836fe59ef

# Install Python and pip
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y python3 python3-pip python3-venv \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Set up Python virtual environment location
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install PostgreSQL client tools
RUN apt-get update && apt-get install -y postgresql-client \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
