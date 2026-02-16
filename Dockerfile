FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system deps needed for some Python packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy application code
COPY . /app

# Run migrations then start the app. Rely on docker-compose service_healthy for postgres.
CMD python3 migrations/apply_migrations.py || true && python3 seed.py || true && uvicorn app:app --host 0.0.0.0 --port 8000
