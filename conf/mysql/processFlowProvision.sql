-- processFlow (jbpm5) provisioning script of mysql RDBMS
-- JA Bride :  22 June 2012

create database if not exists guvnor;
grant all on guvnor.* to 'guvnor'@${brmsWebs.db.ip.addr} identified by 'guvnor';

create database if not exists jbpm;
grant all on jbpm.* to 'jbpm'@${brmsWebs.db.ip.addr} identified by 'jbpm';

create database if not exists jbpm_bam;
grant all on jbpm_bam.* to 'jbpm_bam'@${brmsWebs.db.ip.addr} identified by 'jbpm_bam';

flush privileges;
