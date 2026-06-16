# -----------------------------------------------
# Dockerfile Template
# -----------------------------------------------
# Build a lean, production-ready container image.
# Every line creates a new layer — order matters
# for caching. Put things that change least first.
# -----------------------------------------------

# -----------------------------------------------
# Base Image
# -----------------------------------------------
# Start from an official image. Use -slim variants
# to keep image size small. Never use :latest in
# production — pin to a specific version.
# -----------------------------------------------
FROM python:3.11-slim                          # FILL IN: your runtime e.g. node:18-slim, python:3.11-slim

# -----------------------------------------------
# Working Directory
# -----------------------------------------------
# All subsequent commands run from this directory.
# Convention is /app — keeps things predictable.
# -----------------------------------------------
WORKDIR /app

# -----------------------------------------------
# Dependencies
# -----------------------------------------------
# Copy requirements FIRST before your code.
# Docker caches this layer — if requirements.txt
# hasn't changed, pip install is skipped on rebuild.
# This saves minutes on every code change.
# -----------------------------------------------
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt  # FILL IN: npm ci, yarn install, etc.

# -----------------------------------------------
# Application Code
# -----------------------------------------------
# Copy code AFTER dependencies so code changes
# don't invalidate the dependency cache layer.
# -----------------------------------------------
COPY . .

# -----------------------------------------------
# Port
# -----------------------------------------------
# Documents which port your app listens on.
# Does NOT actually publish the port — that's
# done at runtime via docker run -p or compose.
# -----------------------------------------------
EXPOSE 8080                                    # FILL IN: your app port

# -----------------------------------------------
# Start Command
# -----------------------------------------------
# The command that runs when the container starts.
# Use exec form (array) not shell form (string)
# so signals like SIGTERM are handled correctly.
# -----------------------------------------------
CMD ["python", "app.py"]                       # FILL IN: your start command