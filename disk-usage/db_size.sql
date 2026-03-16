  SELECT   (SELECTSUM(bytes)/1024/1024/1024 data_size
            FROM dba_data_files)
       + (SELECT NVL (SUM (bytes), 0) / 1024 / 1024 / 1024 temp_size
            FROM dba_temp_files)
       + (SELECT SUM (bytes) / 1024 / 1024 / 1024 redo_size FROM sys.v_$log)
       + (SELECT SUM (BLOCK_SIZE * FILE_SIZE_BLKS) / 1024 / 1024 / 1024
                    controlfile_size
            FROM v$controlfile)
          Size_in_GB
  FROM DUAL;

