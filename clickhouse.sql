--- Filter useless error log
egrep '<Error>' /var/log/clickhouse-server/clickhouse-server.err.log | egrep -v '<Error> .* (Poco::Exception. Code: 1000|DB::NetException: Connection reset by peer|DB::Exception: Syntax error|DB::NetException:.* while writing to socket|DB::Exception: Attempt to read after eof|DB::Exception: Unknown identifier|DB::Exception: ZooKeeper session has been expired|Coordination::Exception: Session expired|Coordination::Exception: Connection loss|DB::Exception: Illegal types of arguments|Coordination::Exception: Operation timeout|DB::NetException: Timeout exceeded while reading from socket|DB::Exception: Too many parts|Removing locally missing part from ZooKeeper and queueing a fetch|DB::Exception: Unknown function|Removing unexpectedly merged local part from ZooKeeper|Ignoring missing local part|Renaming unexpected part|DB::Exception: Column .* is not under aggregate function and not in GROUP BY|DB::Exception: Timeout exceeded|DB::Exception: Limit for .* bytes to read exceeded|DB::Exception: Unknown user default|DB::Exception: Password required for user|DB::Exception: Table .* do.*t exist|DB::Exception: Database .* do.*t exist|DB::Exception: Cannot write to ostream at offset|DB::Exception: Quota for user.* has been exceeded|DB::Exception: Illegal type.*of argument for aggregate function|DB::Exception: Memory limit.*exceeded|DB::Exception: Wrong column name. Cannot find column .* to drop|Cannot enqueue replicated DDL query for a replicated shard|Replica .* appears to be already active|Aggregate function .* is found inside another aggregate function|TABIX_QUERY|DB::Exception: Unknown packet 10 from client)' | tail -n 10

--- Queries
/* Find erred query
2021.10.22 10:56:37.599453 [ 20998 ] {b0d3785d-a04c-4e2a-9e42-e182bebfde73} <Error> DynamicQueryHandler: Code: 117, e.displayText() = DB::Exception: Unexpected symbol '' for key 'click.longitude': (at row 257)*/
SELECT
    event_time,
    query,
    exception
FROM system.queries
WHERE (event_date = today()) AND (query_id = 'b0d3785d-a04c-4e2a-9e42-e182bebfde73') AND (type > 1);
