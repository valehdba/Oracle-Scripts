 SELECT Total.name "Tablespace name",
         NVL (Free_space, 0) "Free space(MB)",
         NVL (total_space - Free_space, 0) "Used space(MB)",
         total_space " Total space(MB)"
    FROM (  SELECT tablespace_name, SUM (bytes / 1024 / 1024) free_space
              FROM sys.dba_free_space
          GROUP BY tablespace_name) Free,
         (  SELECT b.name, SUM (bytes / 1024 / 1024) total_space
              FROM sys.v_$datafile a, sys.v_$tablespace B
             WHERE a.ts# = b.ts#
          GROUP BY b.name) Total
   WHERE Free.Tablespace_name(+) = Total.name
ORDER BY Total.name;
