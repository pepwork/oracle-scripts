rem ------------------------------------------------------------------
rem  PeP Software Development
rem ------------------------------------------------------------------
rem  Projekt..........: PePWork
rem  Script...........: directory.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 19.01.2013
rem  Version..........: 1.0.0
rem  Parameter........: 1 Database Directory
rem                     2 Directory Path
rem  Output...........: -
rem  Description......: Create a new database directory.
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem  1.0.0   19.01.2013 pep      Created
rem ------------------------------------------------------------------

set serveroutput on

define newdbdirectory = &1
define newdbdirectorypath = &2

prompt Creating database directory &newdbdirectory for &newdbdirectorypath
create or replace directory &newdbdirectory as '&newdbdirectorypath';
