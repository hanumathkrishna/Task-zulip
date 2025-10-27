FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential ca-certificates curl git \
    libpq-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev locales \
    nodejs npm \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 zulip || true \
 && useradd -r -u 1000 -g zulip -m -d /home/zulip -s /bin/bash zulip || true \
 && mkdir -p /data /home/zulip/deployments/current /app

WORKDIR /app

COPY . /app

RUN chown -R zulip:zulip /app /data /home/zulip

RUN pip install --upgrade pip setuptools wheel
RUN if [ -f requirements/dev.txt ]; then \
      pip install -r requirements/dev.txt ; \
    elif [ -f requirements/prod.txt ]; then \
      pip install -r requirements/prod.txt ; \
    elif [ -f requirements.txt ]; then \
      pip install -r requirements.txt ; \
    else \
      echo "No requirements file found, skipping pip install"; \
    fi

RUN if [ -f package.json ]; then \
      npm ci --no-audit --no-fund || npm install --no-audit --no-fund ; \
    fi

USER zulip
ENV HOME=/home/zulip

EXPOSE 9991

CMD ["sh", "-c", "cd /app && python3 manage.py migrate --noinput || true && python3 manage.py runserver 0.0.0.0:9991"]
