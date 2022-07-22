-- Dump DB ---
mysqldump --defaults-file=/etc/mysql/debian.cnf --routines --events --triggers ${DB} ${TABLE:}> ${DB}.${TABLE:}.${DATE}.sql

--- Schema only
mysqldump --defaults-file=/etc/mysql/debian.cnf --no-data ${DB} ${TABLE:}> ${DB}.${TABLE:}.${DATE}.sql

--- Export the related part for a table from mysqldump's generate file
sed -n -e '/DROP TABLE.*`${TABLE}`/,/UNLOCK TABLES/p' dump.sql > dump.${TABLE}.sql

-- DDL ---

--- RENAME TABLE ${TABLE} TO ${NEW_TABLE}
ALTER TABLE ${TABLE} RENAME TO ${NEW_TABLE};

--- CREATE INDEX ${INDEX} on ${TABLE} (columnA, columnB, ...)
ALTER TABLE ${TABLE} ADD INDEX ${INDEX} (columnA, columnB, ...)

--- Change collation
ALTER DATABASE ${DB} CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE ${DB}.${TABLE} CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE ${DB}.${TABLE} MODIFY ${COLUMN} CHARACTER SET utf8 COLLATE utf8_unicode_ci default '' not null;

/* with PT-ONLINE-SCHEMA-CHANGE
https://www.percona.com/doc/percona-toolkit/3.0/pt-online-schema-change.html */
--- For big tables: --max-load Threads_running=20000 --critical-load Threads_running=20000
/usr/bin/pt-online-schema-change --defaults-file=/etc/mysql/debian.cnf --alter='${DDL_QUERY1}, ${DDL_QUERY2}' D=${DB},t=${TABLE} --dry-run

--- Insight ---
/* Size of DB, Table
https://chartio.com/resources/tutorials/how-to-get-the-size-of-a-table-in-mysql/ */
SELECT
    TABLE_SCHEMA AS 'DB Name',
    ROUND(SUM(DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 1) AS 'DB Size in MB'
FROM
    information_schema.TABLES
WHERE
    TABLE_SCHEMA = '${DB}'
GROUP BY
    TABLE_SCHEMA;

SELECT
    TABLE_NAME AS `Table`,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024) AS `Size (MB)`
FROM
    information_schema.TABLES
WHERE
        TABLE_SCHEMA = "${DB}"
    AND
        TABLE_NAME = "${TABLE}"
GROUP BY
    TABLE_NAME;

SELECT
    TABLE_NAME, TABLE_ROWS
FROM
    INFORMATION_SCHEMA.TABLES
WHERE
        TABLE_SCHEMA = '${DB}'
    AND
        TABLE_NAME = '${TABLE}'
GROUP BY
    TABLE_NAME;

--- Extract transaction log
mysqlbinlog --short-form --start-datetime="2021-11-12 08:00:00" --stop-datetime="2021-11-12 11:01:00" --database=${DB} --table=${TABLE} /var/log/mysql/mariadb-bin.xyz >> ${DB}.${TABLE}.binlog

--- KILL ---
--- Kill all sleeping process from an user
select group_concat(concat('KILL ',id,';') separator ' ') from information_schema.processlist where user='${USER}' and command = "Sleep";
