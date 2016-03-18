rem ------------------------------------------------------------------
rem  PeP Software Development
rem ------------------------------------------------------------------
rem  Projekt..........: PePWork
rem  Script...........: dropdbobjects.sql
rem  Developer........: Perry Pakull (pep), perry.pakull@trivadis.com
rem  Date.............: 19.01.2013
rem  Version..........: 1.0.0
rem  Parameter........: -
rem  Output...........: -
rem  Description......: Drop all objects from the logon user.
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem  1.0.0   19.01.2013 pep      Created
rem  1.0.0   20.06.2014 pep      Include PURGE for DROP TABLE
rem ------------------------------------------------------------------

set serveroutput on

declare
   l_count                    pls_integer;
   l_dbname                   varchar2 (100);
   l_stmt                     varchar2 (32767);
   e_sys_user                 exception;
begin
   if user in ('SYS','SYSTEM')
   then
      raise e_sys_user;
   end if;
   --
   dbms_output.put_line ('Drop all User Objects');
   dbms_output.put_line ('--------------------------------------------------- ');
   select count (*) into l_count from user_objects;
   select global_name into l_dbname from global_name;
   dbms_output.put_line ('Database.... : ' || l_dbname);
   dbms_output.put_line ('User........ : ' || user);
   dbms_output.put_line ('Date........ : ' || to_char (sysdate, 'DD.MM.YYYY HH24:MI:SS'));
   dbms_output.put_line ('User Objects : ' || l_count);
   dbms_output.put_line ('--------------------------------------------------- ');
   --
   begin
      for r_obj in (select uo.*
                      from user_objects uo
                     where uo.object_type not in ('TRIGGER', 'INDEX', 'PACKAGE BODY', 'LOB')
                       and uo.object_name not like 'BIN$%'
                    order by uo.object_type, uo.object_name)
      loop
         l_stmt := 'drop ' || r_obj.object_type || ' ' || r_obj.object_name;
         if r_obj.object_type = 'TABLE'
         then
            l_stmt := l_stmt || ' cascade constraints purge';
         end if;
         if r_obj.object_type = 'TYPE'
         then
            l_stmt := l_stmt || ' force';
         end if;
         l_stmt := l_stmt;
         dbms_output.put (l_stmt || ' ... ');
         begin
            execute immediate l_stmt;
            dbms_output.put_line (' dropped! ');
         exception
            when others
            then
               dbms_output.put_line (' Error : ' || sqlerrm);
         end;
      end loop;
      --
      execute immediate 'purge recyclebin';
      dbms_output.put_line ('purge recyclebin');
      --
      select count (*) into l_count from user_objects;
      if l_count = 0
      then
         dbms_output.put_line ('All Objects dropped');
      else
         dbms_output.put_line (l_count || ' objects not dropped');
      end if;
   exception
      when e_sys_user
      then
         dbms_output.put_line ('Do not drop objects of System Users');
      when others
      then
         dbms_output.put_line ('Error : ' || sqlerrm);
   end;
end;
/
