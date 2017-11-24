rem ------------------------------------------------------------------
rem  Trivadis AG, Oracle Application Development
rem ------------------------------------------------------------------
rem  Projekt..........: PeP Development
rem  Script...........: compiler.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 15.05.2013
rem  Version..........: 2.0.0
rem  Parameter........: -
rem  Output...........: -
rem  Description......: Compiling invalid objects of logon user.
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem  2.0.0   15.05.2013 pep      Created
rem ------------------------------------------------------------------

set serveroutput on

set heading off
set feedback off

declare
   l_stmt                     varchar2 (32767);
begin
   dbms_output.put_line ('Compiling invalid objects for user ' || user);
   for r in (select object_name,
                    object_type
               from user_objects
              where status = 'INVALID'
             order by object_type,
                      object_name)
   loop
      dbms_output.put_line('Compile ' || r.object_type || ' ' || r.object_name);
      l_stmt := null;
      if r.object_type = 'JAVA CLASS'
      then
         l_stmt := 'alter java class ' || user || '.' || r.object_name || ' compile';
      elsif r.object_type = 'PACKAGE BODY'
      then
         l_stmt := 'alter package ' || r.object_name || ' compile body';
      elsif r.object_type = 'INDEX'
      then
         l_stmt := 'alter index ' || r.object_name || ' rebuild';
      elsif r.object_type = 'TYPE BODY'
      then
         l_stmt := 'alter type ' || r.object_name || ' compile body';
      else
         l_stmt := 'alter ' || r.object_type || ' ' || r.object_name || ' compile';
      end if;
      dbms_output.put_line(l_stmt);
      begin
         execute immediate l_stmt;
      exception
         when others
         then
            null;
      end;
   end loop;
end;
/

set heading on
set feedback 6

prompt
prompt Invalid Objects after compile ...
prompt
col object_name format a50
select object_type,
       object_name
  from user_objects
 where status = 'INVALID';
