SELECT DECODE (GROUPING (nm), 1, 'TOTAL', nm) nm,
         ROUND (SUM (val / 1024 / 1024)) mb
    FROM (SELECT 'SGA' nm, SUM (VALUE) val FROM v$sga
          UNION ALL
          SELECT 'PGA', SUM (VALUE)
            FROM v$sysstat
           WHERE name = 'session pga memory')
GROUP BY ROLLUP (nm);
