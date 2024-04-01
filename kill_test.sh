# git clone --depth 1 --single-branch --branch PGPRO-8954_from_PGPRO_14_7 https://git.postgrespro.ru/pgpro-dev/pg_filedump.git pg_filedump
# git clone --depth 1 --single-branch --branch ent-14.7.1.cert https://git.postgrespro.ru/pgpro-dev/postgrespro.git ent-14
# git clone https://git.postgrespro.ru/a.bille/random_bytea.git

export PG=/pgpro/ent-14
export PGBIN=$PG/bin
export PGDATA=$PG/data
export PG_CONFIG=$PGBIN/pg_config
export PATH=$PGBIN:$PATH

pg_ctl -l $PG/file.log start
psql test -c "vacuum t;"

backend_pid=`psql test -t -P format=unaligned -c "select pid from pg_stat_activity where query like '%vacuuming t%' and pid!=pg_backend_pid()"`
echo "Backend pid is $backend_pid"

kill -9 $backend_pid;

until psql test -c "select 1"
do
    echo "Waiting server start"
    sleep 1
done

psql test -c "insert into t(data) values('\x01')"
echo psql_exit_status $?

t=$(psql test -tc "SELECT pg_relation_filepath('t');")
pg_filedump -f -x -i $PGDATA/${t/' '} > result_t.dump
t=$(psql test -tc "SELECT pg_relation_filepath('t_data_idx');")
pg_filedump -f -x -i $PGDATA/${t/' '} > result_t_data_idx.dump

# t='psql test -tc "SELECT pg_relation_filepath('t');"'
# pg_filedump -D bigint,bytea $PGDATA/$t}

pg_ctl stop