create extension random_bytea;
create table t (id bigserial, data bytea);
-- insert into t (data) select random_bytea(10) FROM generate_series(1, 100000000);
insert into t (data) select random_bytea(10) FROM generate_series(1, 10000000);
create index t_data_idx on t (data);
checkpoint;
-- delete from t where id in (select id from t order by random() limit 90000000);
delete from t where id in (select id from t order by random() limit 9000000);
--VACUUM t;