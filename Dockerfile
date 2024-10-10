ARG PYTHON_VERSION=3.11
FROM python:$PYTHON_VERSION

# Set environment variables
ENV FLASK_APP=superset
ENV GUNICORN_BIND=0.0.0.0:8088
ENV GUNICORN_LIMIT_REQUEST_FIELD_SIZE=8190
ENV GUNICORN_LIMIT_REQUEST_LINE=4094
ENV GUNICORN_THREADS=4
ENV GUNICORN_TIMEOUT=120
ENV GUNICORN_WORKERS=10
ENV GUNICORN_WORKER_CLASS=gevent
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONPATH=/etc/superset:/home/superset
ENV SUPERSET_HOME=/var/lib/superset
ENV GUNICORN_CMD_ARGS="--bind $GUNICORN_BIND --limit-request-field_size $GUNICORN_LIMIT_REQUEST_FIELD_SIZE --limit-request-line $GUNICORN_LIMIT_REQUEST_LINE --threads $GUNICORN_THREADS --timeout $GUNICORN_TIMEOUT --workers $GUNICORN_WORKERS --worker-class $GUNICORN_WORKER_CLASS"

# Configure filesystem
COPY bin /usr/local/bin
VOLUME /etc/superset /home/superset /var/lib/superset

# Create superset user and install dependencies
WORKDIR /home/superset
RUN groupadd supergroup && \
    useradd -U -G supergroup superset && \
    mkdir -p $SUPERSET_HOME /etc/superset && \
    chown -R superset:superset $SUPERSET_HOME /home/superset /etc/superset && \
    apt-get update && apt-get install -y \
    build-essential lsb-release gpg curl \
    default-libmysqlclient-dev freetds-bin freetds-dev \
    libaio1 libecpg-dev libffi-dev libldap2-dev \
    libpq-dev libsasl2-2 libsasl2-dev libsasl2-modules-gssapi-mit \
    libssl-dev && \
    curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list && \
    apt-get update && apt-get install -y redis-server postgresql && \
    pip install -U pip psycopg2 && \
    apt-get clean

# Install Python dependencies
COPY requirements*.txt ./
RUN pip install -r requirements.txt && \
    pip install -r requirements-dev.txt

# Customize Superset with your configuration and logos
COPY superset_config.py /etc/superset/
COPY superset-logo-horiz.png /usr/local/lib/python3.11/site-packages/superset/static/assets/images/
COPY favicon.png /usr/local/lib/python3.11/site-packages/superset/static/assets/images/
ENV SUPERSET_CONFIG_PATH=/etc/superset/superset_config.py

# Expose port and health check
EXPOSE 8088
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8088/health || exit 1

# Run Superset
CMD ["gunicorn", "superset.app:create_app()"]
