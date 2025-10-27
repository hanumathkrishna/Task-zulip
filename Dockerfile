FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    HOME=/home/zulip

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential ca-certificates curl git \
    libpq-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev locales \
    nodejs npm python3-venv \
  && rm -rf /var/lib/apt/lists/*

# Create zulip user/group early
RUN groupadd -g 1000 zulip || true \
 && useradd -r -u 1000 -g zulip -m -d /home/zulip -s /bin/bash zulip || true \
 && mkdir -p /data /home/zulip/deployments/current /app

WORKDIR /app
COPY . /app

# Ensure correct ownership before installing node deps
RUN chown -R zulip:zulip /app /data /home/zulip

# install virtualenv and create a venv at /app/.venv (virtualenv provides activate_this.py)
RUN pip install --upgrade pip setuptools wheel virtualenv \
 && virtualenv /app/.venv

# Install Python deps into the venv
RUN /app/.venv/bin/pip install --upgrade pip
RUN if [ -f requirements/dev.txt ]; then \
      /app/.venv/bin/pip install -r requirements/dev.txt ; \
    elif [ -f requirements/prod.txt ]; then \
      /app/.venv/bin/pip install -r requirements/prod.txt ; \
    elif [ -f requirements.txt ]; then \
      /app/.venv/bin/pip install -r requirements.txt ; \
    fi

# Install frontend deps as zulip user (so node_modules owned by zulip)
USER zulip
RUN if [ -f /app/package.json ]; then \
      cd /app && npm ci --no-audit --no-fund ; \
    fi

EXPOSE 9991

# Run using the venv python so manage.py finds venv and run as zulip user
CMD ["/app/.venv/bin/python3", "/app/manage.py", "runserver", "0.0.0.0:9991"]
