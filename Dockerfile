############################################################
# Stage 1 — Build Frontend
############################################################
FROM node:20-slim AS frontend-builder

WORKDIR /app

# Dependências necessárias (inclui zstd)
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Criar pastas esperadas pelo build
RUN mkdir -p /app/superset/static/assets

WORKDIR /app/superset-frontend

COPY superset-frontend/package.json .
COPY superset-frontend/package-lock.json .
RUN npm ci

COPY superset-frontend/ .

# Build frontend (vai gerar arquivos em /app/superset/static/assets)
RUN npm run build


############################################################
# Stage 2 — Backend Production
############################################################
FROM python:3.11-slim

ENV SUPERSET_HOME=/app/superset_home \
    SUPERSET_ENV=production \
    FLASK_APP="superset.app:create_app()" \
    PYTHONPATH="/app/pythonpath" \
    SUPERSET_PORT=8088

WORKDIR /app

# Dependências do sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    libsasl2-dev \
    libldap2-dev \
    curl \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Criar usuário superset
RUN useradd --create-home --shell /bin/bash superset

# Copia código backend
COPY . /app

# Atualiza pip
RUN pip install --upgrade pip setuptools wheel

# Instala psycopg2
RUN pip install --no-cache-dir psycopg2-binary==2.9.6

# Instala Superset
RUN pip install --no-cache-dir -e .

# Copia assets gerados pelo frontend
COPY --from=frontend-builder /app/superset/static/assets \
    /app/superset/static/assets

# Sobrescreve logo e favicon
COPY static/assets/images/logo_custom.png \
     /app/superset/static/assets/images/logo_custom.png

COPY static/assets/favicons/favicon_custom.png \
     /app/superset/static/assets/favicons/favicon_custom.png

RUN chown -R superset:superset /app

USER superset

EXPOSE 8088

CMD ["superset", "run", "-h", "0.0.0.0", "-p", "8088"]