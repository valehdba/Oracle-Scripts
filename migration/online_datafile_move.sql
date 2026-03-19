-- ============================================================
-- Script: generate_move_datafiles.sql
-- Purpose: Generate ALTER DATABASE MOVE DATAFILE commands
--          for moving datafiles to a new mountpoint on standby
-- ============================================================

-- Configure output
SET PAGESIZE 0
SET LINESIZE 300
SET FEEDBACK OFF
SET HEADING OFF
SET TRIMSPOOL ON
SET ECHO OFF
SET VERIFY OFF

-- Define variables
DEFINE source_path = '/u01/app/oracle/oradata/LSIMTEST/datafile'
DEFINE target_path = '/u04/oradata/lsimtest'

SPOOL /home/oracle/move_datafiles.sql

-- Step 1: Cancel managed recovery
SELECT '-- ============================================================' FROM dual;
SELECT '-- Generated: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') FROM dual;
SELECT '-- Move datafiles from &source_path' FROM dual;
SELECT '-- To &target_path' FROM dual;
SELECT '-- ============================================================' FROM dual;
SELECT '' FROM dual;

SELECT '-- Step 1: Cancel managed recovery' FROM dual;
SELECT 'ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;' FROM dual;
SELECT '' FROM dual;

SELECT '-- Step 2: Open read only (Active Data Guard)' FROM dual;
SELECT 'ALTER DATABASE OPEN READ ONLY;' FROM dual;
SELECT '' FROM dual;

SELECT '-- Step 3: Backup controlfile before move' FROM dual;
SELECT '-- Run in RMAN: BACKUP CURRENT CONTROLFILE;' FROM dual;
SELECT '' FROM dual;

SELECT '-- Step 4: Move datafiles' FROM dual;
SELECT '-- Total datafiles to move: ' || COUNT(*) 
FROM v$datafile 
WHERE name LIKE '&source_path%';

SELECT '' FROM dual;

-- Generate move commands with non-OMF filenames
SELECT 'ALTER DATABASE MOVE DATAFILE ''' || name || '''' ||
       ' TO ''' || '&target_path' || '/' ||
       -- Replace OMF name with clean tablespace-based name
       LOWER(
         (SELECT tablespace_name FROM dba_data_files WHERE file_id = f.file#)
       ) || '_' ||
       LPAD(
         (SELECT ROW_NUMBER() OVER (PARTITION BY tablespace_name ORDER BY file_id)
          FROM dba_data_files WHERE file_id = f.file#), 2, '0'
       ) || '.dbf'';'
FROM v$datafile f
WHERE name LIKE '&source_path%'
ORDER BY file#;

SELECT '' FROM dual;

SELECT '-- Step 5: Verify new datafile locations' FROM dual;
SELECT 'SELECT file#, name, status FROM v$datafile ORDER BY file#;' FROM dual;
SELECT '' FROM dual;

SELECT '-- Step 6: Restart managed recovery' FROM dual;
SELECT 'ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;' FROM dual;
SELECT '' FROM dual;

SELECT '-- Step 7: Verify recovery is applying' FROM dual;
SELECT 'SELECT sequence#, applied FROM v$archived_log' FROM dual;
SELECT 'ORDER BY sequence# DESC FETCH FIRST 10 ROWS ONLY;' FROM dual;

SPOOL OFF
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 14

PROMPT
PROMPT ============================================================
PROMPT Script generated: /home/oracle/move_datafiles.sql
PROMPT Review the script before executing!
PROMPT ============================================================
PROMPT
