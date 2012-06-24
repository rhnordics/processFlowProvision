-- processFlow (jbpm5) provisioning script of mysql RDBMS
-- JA Bride :  22 June 2012

create database if not exists guvnor;
grant all on guvnor.* to 'guvnor'@${brmsWebs.db.ip.addr} identified by 'guvnor';
-- set password for guvnor = password('guvnor');

flush privileges;
