# git clone --depth 1 --single-branch --branch PGPRO-8954_from_PGPRO_14_7 https://git.postgrespro.ru/pgpro-dev/pg_filedump.git pg_filedump
# git clone --depth 1 --single-branch --branch ent-14.7.1.cert https://git.postgrespro.ru/pgpro-dev/postgrespro.git ent-14
# git clone https://git.postgrespro.ru/a.bille/random_bytea.git

export PG=/pgpro/ent-14
export PGBIN=$PG/bin
export PGDATA=$PG/data
export PG_CONFIG=$PGBIN/pg_config
export PATH=$PGBIN:$PATH

pg_ctl stop
pg_ctl -l $PG/file.log start
dropdb test
createdb test
psql test -f script.sql
psql_pid=$!;
echo "script pid=$psql_pid"

#nohup vacuumdb -d test -t t --force-index-cleanup
psql test -c "/*vacuuming t*/ vacuum t;" &
psql_pid=$!;
echo "vacuum psql pid=$psql_pid"
sleep 0.4

backend_pid=`psql test -t -P format=unaligned -c "select pid from pg_stat_progress_vacuum"`
echo "vacuum backend pid = $backend_pid"

kill -9 $backend_pid
echo "kill status $?"

psql_pid=$!;
echo "vacuum backend shell pid = $psql_pid"

until psql test -c "select 1"
do
    echo "Waiting server start"
    sleep 1
done

psql test -c "insert into t(data) values('\x01')"
echo "psql insert pid=$!, exit_code=$?"

t=$(psql test -tc "SELECT pg_relation_filepath('t');")
t=$PGDATA/${t/' '}
echo "table t file=$t"
pg_filedump -f -i $t > result_t.dump
#pg_filedump -f -i $PGDATA/${t/' '} > result_t.dump

t=$(psql test -tc "SELECT pg_relation_filepath('t_data_idx');")
t=$PGDATA/${t/' '}
echo "index t_data_idx file=$t"
pg_filedump -f -x -i $t > result_t_data_idx.dump
#pg_filedump -f -x -i $PGDATA/${t/' '} > result_t_data_idx.dump

pg_ctl stop