############################################################
# Stage 1 — Build Frontend
############################################################
FROM node:20-slim AS frontend-builder

WORKDIR /app/superset-frontend

COPY superset-frontend/package*.json ./
RUN npm ci

COPY superset-frontend/ .
RUN npm run build


############################################################
# Stage 2 — Backend (Produção)
############################################################
FROM python:3.11-slim

ENV SUPERSET_HOME=/app/superset_home \
    SUPERSET_ENV=production \
    FLASK_APP="superset.app:create_app()" \
    SUPERSET_PORT=8088

WORKDIR /app

# Dependências do sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Criar usuário não-root
RUN useradd --create-home --shell /bin/bash superset

# Copiar código do projeto
COPY . /app

# Atualizar pip
RUN pip install --upgrade pip setuptools wheel

# Instalar dependências essenciais do Superset
RUN pip install --no-cache-dir -r requirements/base.txt

# Instalar driver PostgreSQL (mantendo psycopg2)
RUN pip install --no-cache-dir psycopg2-binary

# Instalar Superset
RUN pip install --no-cache-dir -e .

# Copiar frontend buildado
COPY --from=frontend-builder /app/superset/static/assets \
    /app/superset/static/assets

# Sobrescrever logo e favicon customizados
COPY static/assets/images/logo_custom.png \
     /app/superset/static/assets/images/logo_custom.png

COPY static/assets/favicons/favicon_custom.png \
     /app/superset/static/assets/favicons/favicon_custom.png

# Copiar config de produção
COPY docker/pythonpath_prod/superset_config.py /app/superset_config.py
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# Ajustar permissões
RUN chown -R superset:superset /app
USER superset

EXPOSE 8088

# Iniciar com Gunicorn (produção)
CMD ["gunicorn", "-w", "4", "-k", "gevent", "-b", "0.0.0.0:8088", "superset.app:create_app()"]