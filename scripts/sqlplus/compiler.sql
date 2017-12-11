----------------------------------------------------------------------
--  GitHub https://github.com/pepwork
----------------------------------------------------------------------
--  Projekt..........: PeP Development
--  Script...........: compiler.sql
--  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
--  Date.............: 15.05.2013
--  Version..........: 2.0.0
--  Parameter........: -
--  Output...........: -
--  Description......: Compiling invalid objects of logon user.
----------------------------------------------------------------------
--  Version Date       Who      What
--  2.0.0   15.05.2013 pep      Created
----------------------------------------------------------------------

set serveroutput on size unlimited
set feedback off
declare
   l_count_invalid            pls_integer;
   l_stmt                     varchar2(32767);
begin
   dbms_output.put_line ('Searching invalid objects for user ' || user);
   select count(*)
     into l_count_invalid
     from user_objects
    where status = 'INVALID';
   dbms_output.put_line ('Found ' || to_char(l_count_invalid) ||' invalid objects for user ' || user);
   if l_count_invalid > 0
   then
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
               dbms_output.put_line('Error compiling object ' || r.object_name);
               dbms_output.put_line(sqlerrm);
         end;
      end loop;
      dbms_output.put_line ('Invalid objects for user ' || user || ' after compile.');
      for r in (select object_name,
                       object_type
                  from user_objects
                 where status = 'INVALID'
                 order by object_type,
                          object_name)
      loop
         dbms_output.put_line(r.object_type || ' ' || r.object_name);
      end loop;
   end if;
end;
/
