#!/bin/bash


psql test -c "/*vacuuming t*/ vacuum t;" &

psql_pid=$!;
echo $psql_pid;
sleep 0.5

backend_pid=`psql test -t -P format=unaligned -c "select pid from pg_stat_activity where query like '%vacuuming t%' and pid!=pg_backend_pid()"`
echo "Backend pid is $backend_pid"

sleep_time=`shuf -i 2-5 -n 1`
echo "Sleeping in $sleep_time sec";
sleep $sleep_time;

kill -9 $backend_pid;

until psql test -c "select 1"
do
    echo "Waiting server start"
    sleep 1
done

psql test -c "insert into t(data) values('\x01')"
exit $?


