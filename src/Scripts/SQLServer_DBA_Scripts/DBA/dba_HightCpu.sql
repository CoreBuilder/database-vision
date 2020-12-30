


CREATE PROCEDURE [dbo].[Firm_DBA_HightCpu]
AS
BEGIN
    SELECT q.[text],
           SUBSTRING(   q.text,
                        (qs.statement_start_offset / 2) + 1,
                        ((CASE qs.statement_end_offset
                              WHEN -1 THEN
                                  DATALENGTH(q.text)
                              ELSE
                                  qs.statement_end_offset
                          END - qs.statement_start_offset
                         ) / 2
                        ) + 1
                    ) AS statement_text,
           qs.last_execution_time,
           qs.execution_count,
           qs.total_worker_time / 1000000 AS total_cpu_time_sn,
           qs.total_worker_time / qs.execution_count / 1000 AS avg_cpu_time_ms,
           qp.query_plan,
           DB_NAME(q.dbid) AS database_name,
           q.objectid,
           q.number,
           q.encrypted
    FROM
    (
        SELECT TOP 50
               qs.last_execution_time,
               qs.execution_count,
               qs.plan_handle,
               qs.total_worker_time,
               qs.statement_start_offset,
               qs.statement_end_offset
        FROM sys.dm_exec_query_stats qs
        WHERE qs.execution_count > 10
        ORDER BY qs.total_worker_time DESC
    ) qs
        CROSS APPLY sys.dm_exec_sql_text(plan_handle) q
        CROSS APPLY sys.dm_exec_query_plan(plan_handle) qp
    WHERE qs.total_worker_time / 1000000 > 3
    ORDER BY qs.total_worker_time DESC;
END;
GO


