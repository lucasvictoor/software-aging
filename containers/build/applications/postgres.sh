#!/bin/bash

install() {
  apt-get update && apt-get install -y postgresql-15 procps
  systemctl disable postgresql
  mkdir -p /usr/local/pgsql/data
  chown -R postgres:postgres /usr/local/pgsql/data
  su - postgres -c "/usr/lib/postgresql/15/bin/initdb -D /usr/local/pgsql/data"
  touch "/usr/local/pgsql/data/logfile"
  chown -R postgres:postgres /usr/local/pgsql/data
}

init() {
  su - postgres -c "/usr/lib/postgresql/15/bin/pg_ctl -D /usr/local/pgsql/data -l /usr/local/pgsql/data/logfile start"
}

monitor() {
  pgrep -f "/usr/lib/postgresql/15/bin/postgres"
}
