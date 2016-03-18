rem ------------------------------------------------------------------
rem  PeP Software Development
rem ------------------------------------------------------------------
rem  Projekt..........: PePWork
rem  Script...........: compiler.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 19.01.2013
rem  Version..........: 1.0.0
rem  Parameter........: -
rem  Output...........: compobj.sql
rem  Description......: Compiling invalid objects of logon user.
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem  1.0.0   19.01.2013 pep      Created
rem ------------------------------------------------------------------

set serveroutput on

set heading off
set feedback off
set linesize 100
set trimspool on
set trimout on

spool compobj.sql

select 'prompt Compiling invalid objects for user ' || user from dual;

select 'prompt Compile ' || object_name || chr (10),
       decode (
          object_type,
          'JAVA CLASS', 'alter java class ' || user || '.',
          'PACKAGE BODY', 'alter package ',
          'TYPE BODY', 'alter type ',
          'ALTER ' || object_type || ' '
       )
       || chr (34)
       || object_name
       || chr (34)
       || decode (
             object_type,
             'INDEX', ' rebuild;',
             'PACKAGE BODY', ' compile body;',
             'TYPE BODY', ' compile body;',
             'JAVA CLASS', ' compile;',
             ' compile;'
          )
          com,
       'show errors'
  from user_objects
 where status = 'INVALID'
order by object_type, object_name;

spool off

set heading on
set feedback 6

start compobj

prompt
prompt Invalid Objects after compile ...
prompt
col object_name format a50
select object_type, object_name
  from user_objects
 where status = 'INVALID';

host del compobj.sql
