import os

# Define a URI do banco de metadados via variável de ambiente
SQLALCHEMY_DATABASE_URI = os.environ.get("SUPERSET_DATABASE_URI")

# Evita SQLite caso a envvar falhe
if not SQLALCHEMY_DATABASE_URI:
    raise ValueError("SUPERSET_DATABASE_URI não definida!")

# Segurança e boas práticas
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY", "unsafe-default")
SQLALCHEMY_TRACK_MODIFICATIONS = True

ENABLE_PROXY_FIX = True


FAVICONS = [{"href": "/static/assets/favicons/favicon_custom.png"}]

THEME_DEFAULT = {
    "brand": {
        "logoPath": "/static/assets/images/logo_custom.png",
        "faviconPath": "/static/assets/favicons/favicon_custom.png",
        "title": "Painel Web - Sisbras",
    },
    "token": {
        "colorPrimary": "#2893B3",
        "colorSuccess": "#5ac189",
        "colorWarning": "#fcc700",
        "colorError": "#e04355",
        "fontFamily": "'Inter', Helvetica, Arial",
    },
    "components": {
        "Menu": {
            "itemBg": "white",
            "itemColor": "black",
        }
    },
}


LANGUAGES = {
    "pt_BR": {"flag": "br", "name": "Português (Brasil)"}
}

BABEL_DEFAULT_LOCALE = 'pt_BR'

# Use D3_FORMAT para forçar o formato
D3_FORMAT = {
    "decimal": ",",
    "thousands": ".",
    "grouping": [3],
    "currency": ["R$", ""]
}

D3_TIME_FORMATS = {
    "date": "%d/%m/%Y",          
    "dateTime": "%d/%m/%Y %H:%M",
    "time": "%H:%M",              
    "year": "%Y",                 
    "month": "%m/%Y",             
}

FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True
}

HTML_SANITIZATION_SCHEMA_EXTENSIONS = {
    "attributes": {
        "*": ["style", "class"],
    },
    "tagNames": ["style"],
}

# Ativa o Talisman para CSP
TALISMAN_ENABLED = True

# Configuração básica do CSP
TALISMAN_CONFIG = {
    "content_security_policy": {
        "default-src": ["'self'"],
        "script-src": ["'self'", "'unsafe-inline'", "'unsafe-eval'", "'blob:'"], # Adicione 'blob:'
        "worker-src": ["'self'", "'blob:'"], # Adicione esta linha
        "style-src": ["'self'", "'unsafe-inline'"],
        "img-src": ["'self'", "data:", "https://apachesuperset.gateway.scarf.sh"], # Adicione a URL
        "font-src": ["'self'", "data:"],
    },
}