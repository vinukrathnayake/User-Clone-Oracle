-- Uncomment if the usernames are not allowed to be created
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
 
-- Opt out headings  
SET PAGESIZE 0;
 
-- Formatting SQL Output
SET PAGES 50000;
SET LINES 10000;
 
PROMPT This Script will CREATE and CLONE priviledges and permissions to a new user from an existing user.
PROMPT
-- Accept values to substitution variables
ACCEPT NEW_USER CHAR PROMPT 'NEW USER Username > '
ACCEPT NEW_USER_PASSWORD CHAR PROMPT 'PASSWORD for NEW USER > '
ACCEPT CLONE_FROM_USER CHAR PROMPT 'CLONE FROM USER (Existing User) > '
 
 
-- Creates a temporary file with the CLONE_FROM_USER privileges and permissions
SPOOL ppuser_&&NEW_USER..sql
 
-- User Creation
CREATE USER &&NEW_USER identified by "&&NEW_USER_PASSWORD";
 
-- Grant Connect
GRANT CONNECT TO &&NEW_USER;
 
-- Retreive CLONE_FROM_USER privileges and permissions
SELECT 'ALTER '||DEFAULT_TABLESPACE||' TO &&NEW_USER;' FROM DBA_USERS WHERE USERNAME=UPPER('&&CLONE_FROM_USER')
UNION ALL
SELECT 'GRANT '||GRANTED_ROLE||' TO &&NEW_USER;' FROM DBA_ROLE_PRIVS WHERE GRANTEE=UPPER('&&CLONE_FROM_USER')
UNION ALL
SELECT 'GRANT '||PRIVILEGE||' TO &&NEW_USER;' FROM DBA_SYS_PRIVS WHERE GRANTEE IN ('&&CLONE_FROM_USER')
UNION ALL
SELECT 'GRANT '||PRIVILEGE||' ON '||OWNER||'.'||TABLE_NAME||' TO &&NEW_USER;' FROM DBA_TAB_PRIVS WHERE GRANTEE IN UPPER('&&CLONE_FROM_USER')
UNION ALL
SELECT 'GRANT '||PRIVILEGE||' ('||COLUMN_NAME||') '||' ON '||OWNER||'.'||TABLE_NAME||' TO &&NEW_USER;' FROM DBA_COL_PRIVS WHERE GRANTEE IN UPPER('&&CLONE_FROM_USER');
 
-- End Of Logging
SPOOL OFF;
 
-- Creates a temporary file with the CLONE_FROM_USER privileges and permissions
@@ppuser_&&NEW_USER..sql
 
-- Deletes the temporary CLONE_FROM_USER privileges and permissions file
 
!rm -rf ppuser_&&NEW_USER..sql

 --Uncomment for Windows Systems and comment the above line
 
 --del ppuser_&&NEW_USER..sql
 
-- Undefines the substitute variables to run as a fresh script when executed again
 
UNDEFINE NEW_USER;
UNDEFINE NEW_USER_PASSWORD;
UNDEFINE CLONE_FROM_USER;
/
