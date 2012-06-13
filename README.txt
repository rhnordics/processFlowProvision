processFlowProvision (aka:  PFP)
====================

one approach toward a production BPM environment leveraging Red Hat BRMS "Deployable" libraries



Jeff Bride

welcome Java developers to Process Flow Provision
you have reached the location where PFP source code is centrally maintained

if you are a JEE and *nix administrator, recommend pointing your browser to 
the following to download a PFP binary distribution :
    http://people.redhat.com/jbride

for Java developers, please review :
    1)  docs/ADMIN_GUIDE.txt 
    2)  docs/DEVELOPER_GUIDE.txt



OVERVIEW
  - PFP is a downstream project to BRMS 5.3 Deployable
  - purpose of PFP :
    - provide an example of one possible production BRMS environment using 
      BRMS deployable libraries
  - PFP github branches :
    - master :  PFP/BRMS targeted for "domain" managed JBoss EAP6
    - eap6-standalone :  PFP/BRMS targeted for "standalone" JBoss EAP6
    - ER6   :   PFP/BRMS ER6 targeted for non-clustered JBoss EAP 5.*




LEGAL
  - PFP is copyright of Red Hat, Inc. and distributed with a LGPL license
  - PFP is maintained by Red Hat Global Solutions and Strategies Office
  - PFP is a community project with no contractual support offerings
  - Please contact Red Hat to discuss support details for BRMS "Deployable"



FEATURES 
1)  automated provisioning
    - Automates provisioning of BRMS deployable libraries on JBoss EAP 5.1
    - Automates Hornetq or MRG-M standalone configuration
    - Provides PostgreSQL configuration templates


2)  centralized configuration
    - centralized configuration of jbpm5 properties during build phase 
      - (via a single build.properties)
    - centralized configuration of jbpm5 properties during the runtime phase 
      - (via properties-service.xml)


3)  database integration
    - integrated and performance tested  using postgresql
    - all jbpm5 / drools components now using one of 3 JCA connection pools:
        1)  jbpm-core-cp
        2)  guvnor-cp
        3)  jbpm-bam
