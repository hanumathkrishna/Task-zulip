FROM python:3.10-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential libpq-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev locales \
    curl git && rm -rf /var/lib/apt/lists/*

# Set up work directory
WORKDIR /app

# Copy the Zulip source code
COPY . /app

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements/dev.txt || pip install -r requirements/prod.txt || true

# Optional: build frontend if needed
RUN if [ -f package.json ]; then \
      apt-get update && apt-get install -y nodejs npm && \
      npm install && npm run build; \
    fi

# Expose port (Zulip usually runs on 9991)
EXPOSE 9991

# Start the application (adjust if different entrypoint)
CMD ["python3", "manage.py", "runserver", "0.0.0.0:9991"]
