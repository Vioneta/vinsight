import os

# Visual Customizations
APP_NAME = "Vinsight"
LOGO_TOOLTIP = "we are vioneta"
PREVENT_UNSAFE_DB_CONNECTIONS = False
# MAPBOX_API_KEY = os.getenv("MAPBOX_API_KEY", "")
CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 300,
    "CACHE_KEY_PREFIX": "vinsight_",
    "CACHE_REDIS_HOST": "127.0.0.1",
    "CACHE_REDIS_PORT": 6379,
    "CACHE_REDIS_DB": 1,
    "CACHE_REDIS_URL": "redis://127.0.0.1:6379/1",
}
FILTER_STATE_CACHE_CONFIG = {**CACHE_CONFIG, "CACHE_KEY_PREFIX": "vinsight_filter_"}
EXPLORE_FORM_DATA_CACHE_CONFIG = {
    **CACHE_CONFIG,
    "CACHE_KEY_PREFIX": "vinsight_explore_form_",
}
SECRET_KEY = "fQUWpWhUVj6HPeSzXNeETPL4IabOk3lZgRdsrj7BG8ndT5ao+4bP5fQ3"
SQLALCHEMY_DATABASE_URI = "postgresql+psycopg2://postgres:postgres@127.0.0.1:5432/vinsight"
SQLALCHEMY_TRACK_MODIFICATIONS = True
# Flask-WTF flag for CSRF
WTF_CSRF_ENABLED = False
# Add endpoints that need to be exempt from CSRF protection
WTF_CSRF_EXEMPT_LIST = []
# A CSRF token that expires in 1 year
WTF_CSRF_TIME_LIMIT = 60 * 60 * 24 * 365
# Set this API key to enable Mapbox visualizations
MAPBOX_API_KEY = ""
