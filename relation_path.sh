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

t=$(psql test -tc "SELECT pg_relation_filepath('t');")
t=$PGDATA/${t/' '}
echo "table t file=$t"
pg_filedump -f -i $t > result_t.dump

t=$(psql test -tc "SELECT pg_relation_filepath('t_data_idx');")
t=$PGDATA/${t/' '}
echo "index t_data_idx file=$t"
pg_filedump -f -x -i $t > result_t_data_idx.dump

pg_ctl stop