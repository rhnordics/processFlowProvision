-- processFlow (jbpm5) provisioning script of mysql RDBMS
-- JA Bride :  22 June 2012

create database if not exists guvnor;
grant CREATE,INSERT,DELETE,UPDATE,SELECT on guvnor.* to guvnor;
set password for guvnor = password('guvnor');

flush privileges;
