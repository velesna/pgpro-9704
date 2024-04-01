export PG=/pgpro/ent-14
export PGBIN=$PG/bin
export PGDATA=$PG/data
export PG_CONFIG=$PGBIN/pg_config
export PATH=$PGBIN:$PATH

pg_ctl stop
pg_ctl -l $PG/file.log start