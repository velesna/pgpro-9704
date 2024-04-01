export PG=/pgpro/ent-14
export PGBIN=$PG/bin
export PGDATA=$PG/data
export PG_CONFIG=$PGBIN/pg_config
export PATH=$PGBIN:$PATH

pg_ctl -l $PG/file.log start

psql test -c "insert into t(data) values('\x01')"
echo psql_exit_status $?

t=$(psql test -tc "SELECT pg_relation_filepath('t_data_idx');")
pg_filedump -f -x -i $PGDATA/${t/' '} > result.dump

pg_ctl stop