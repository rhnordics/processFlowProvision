-- processFlow (jbpm5) provisioning script of mysql RDBMS
-- JA Bride :  22 June 2012

-- cat $PFP_HOME/conf/mysql/processFlowProvision.sql | mysql -u root -p mysql

create database if not exists guvnor;
grant all on guvnor.* to 'guvnor'@'localhost' identified by 'guvnor';
grant all on guvnor.* to 'guvnor'@'%' identified by 'guvnor';

create database if not exists jbpm;
grant all on jbpm.* to 'jbpm'@'localhost' identified by 'jbpm';
grant all on jbpm.* to 'jbpm'@'%' identified by 'jbpm';

create database if not exists jbpm_bam;
grant all on jbpm_bam.* to 'jbpm_bam'@'localhost' identified by 'jbpm_bam';
grant all on jbpm_bam.* to 'jbpm_bam'@'%' identified by 'jbpm_bam';

create database if not exists bizapp;
grant all on bizapp.* to 'bizapp'@'localhost' identified by 'bizapp';
grant all on bizapp.* to 'bizapp'@'%' identified by 'bizapp';

flush privileges;
