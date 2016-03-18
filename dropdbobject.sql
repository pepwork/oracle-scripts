rem ------------------------------------------------------------------
rem  PeP Software Development
rem ------------------------------------------------------------------
rem  Projekt..........: PePWork
rem  Script...........: dropdbobject.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 19.01.2013
rem  Version..........: 1.0.0
rem  Parameter........: 1 Object Type
rem                     2 Object Name
rem  Output...........: -
rem  Description......: Check if object exists and drop the object
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem  1.0.0   19.01.2013 pep      Created
rem  1.0.0   20.06.2014 pep      Include PURGE for DROP TABLE
rem ------------------------------------------------------------------

set serveroutput on
set feedback off
set verify off

declare
   l_count                    pls_integer;
   l_object_type              user_objects.object_type%type := '&1';
   l_object_name              user_objects.object_name%type := '&2';
   l_stmt                     varchar2(32767);
begin
   select count (*)
     into l_count
     from user_objects
    where object_type = upper (l_object_type)
      and object_name = upper (l_object_name);
   if l_count = 1
   then
      l_stmt := 'drop ' || l_object_type || ' ' || l_object_name;
      if upper (l_object_type) = 'TABLE'
      then
         l_stmt := l_stmt || ' cascade constraints purge';
      elsif upper (l_object_type) = 'TYPE'
      then
         l_stmt := l_stmt || ' force';
      end if;
      begin
         execute immediate l_stmt;
         dbms_output.put_line (l_object_type || ' ' || l_object_name || ' dropped');
      exception
         when others
         then
            dbms_output.put_line (l_object_type || ' ' || l_object_name || ' not dropped. ' || sqlerrm);
      end;
   end if;
end;
/

set feedback on
set verify on
