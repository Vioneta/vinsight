ARG PYTHON_VERSION=3.11
FROM python:$PYTHON_VERSION
USER root
# Configure environment
# superset/gunicorn recommended defaults:
# - https://superset.apache.org/docs/installation/configuring-superset#running-on-a-wsgi-http-server
# - https://docs.gunicorn.org/en/latest/configure.html
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
VOLUME /etc/superset
VOLUME /home/superset
VOLUME /var/lib/superset
# Create superset user & install dependencies
WORKDIR /home/superset
RUN groupadd supergroup && \
    useradd -U -G supergroup superset && \
    mkdir -p $SUPERSET_HOME && \
    mkdir -p /etc/superset && \
    chown -R superset:superset $SUPERSET_HOME && \
    chown -R superset:superset /home/superset && \
    chown -R superset:superset /etc/superset && \
    apt-get update && \
    apt-get install -y \
    build-essential \
    lsb-release \
    gpg \
    curl \
    default-libmysqlclient-dev \
    freetds-bin \
    freetds-dev \
    libaio1 \
    libecpg-dev \
    libffi-dev \
    libldap2-dev \
    libpq-dev \
    libsasl2-2 \
    libsasl2-dev \
    libsasl2-modules-gssapi-mit \
    libssl-dev && \
    apt-get clean && \
    pip install -U pip
#installing redis server
RUN curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
RUN chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" |  tee /etc/apt/sources.list.d/redis.list
RUN apt-get update  && \
apt-get install redis -y
#installing posgresql
RUN apt-get install postgresql -y && \
    pip install psycopg2
#start postgresql
RUN service posgresql enable
RUN Service posgresql start
# Install pips
COPY requirements*.txt ./
RUN pip install -r requirements.txt && \
    pip install -r requirements-dev.txt
COPY superset_config.py /etc/superset/
COPY superset-logo-horiz.png /usr/local/lib/python3.11/site-packages/superset/static/assets/images/superset-logo-horiz.png
COPY favicon.png  /usr/local/lib/python3.11/site-packages/superset/static/assets/images/favicon.png
ENV SUPERSET_CONFIG_PATH  /etc/superset/superset_config.py
# Configure application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["gunicorn", "superset.app:create_app()"]
