FROM mcr.microsoft.com/devcontainers/typescript-node:4-24-bookworm@sha256:2baba848f88e02278bcf59e072752f7371534ccfc67afcd8e0ee6b293865c6f9

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
