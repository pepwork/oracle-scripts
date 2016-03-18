rem ------------------------------------------------------------------
rem  PeP Software Development
rem ------------------------------------------------------------------
rem  Projekt..........: PePWork
rem  Script...........: user.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 19.01.2013
rem  Version..........: 1.0.0
rem  Parameter........: 1 Username
rem                     2 Password
rem                     3 Default Tablespace
rem                     4 Temporary Tablespace
rem  Output...........: -
rem  Description......: Create a new User, drop the User when exists.
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem  1.0.0   19.01.2013 pep      Created
rem  1.0.1   09.07.2014 pep      Grant role connect, resource to new user
rem ------------------------------------------------------------------

prompt
prompt ....INSTALLING USER &newuser
prompt

set serveroutput on
set verify off

define newuser = &1
define newpwd = &2
define defts = &3
define tmpts = &4

set feedback off

declare
   l_username                 varchar2(50);
begin
   select username into l_username from dba_users where username = upper('&newuser');
   dbms_output.put_line ('drop user &newuser cascade ...');
   execute immediate ('drop user &newuser cascade');
exception
   when no_data_found then null;
end;
/

set feedback 6

prompt Create new user &newuser
create user &newuser identified by &newpwd default tablespace &defts temporary tablespace &tmpts;
prompt Grant roles connect, resource to &newuser
grant connect, resource to &newuser;

set verify on
