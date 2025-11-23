FROM mcr.microsoft.com/devcontainers/typescript-node:4-24-bookworm@sha256:a13b8f84b610f4a75186ed7c077b415a4b342dfd4e3b33420b8f8f9028da0347

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
