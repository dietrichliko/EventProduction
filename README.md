# Creating MC Samples using CMSCONNECT

[CMS Connect](https://connect.uscms.org/) is a service designed to provide a Tier3-like environment for condor analysis jobs and enables users to 
submit to all resources available in the CMS Global Pool. It is a complementary service to CRAB. It is well suited
to run  small scale production of simulation. Follow the instructions in the 
[Workbook](https://twiki.cern.ch/twiki/bin/view/CMSPublic/WorkBookCMSConnect) to get access.

To avoid difficulties with datatransfers of results, it is suggested to run the simulation on one site and copy results to the local storage 
element. In the example files the jobs are run on the grid site T2_AT_Vienna and data is stored on our local EOS. Contact your local grid
expert to understand the parameters required for your site and modify the scripts accordingly.

## General principle

The generation of events follows three steps, producing GEN-SIM, HLT and AODSIM output. Generally only the last file is required and 
transferred to the Storage Element. The procedure is described in detail in the 
[EventProductionExamplesTool](https://github.com/cms-opendata-analyses/EventProductionExamplesTool) repository.

Following additional workarounds and features for a small scale production

* __Singularity container__: Jobs are run within a singularity container [cmsopendata/cmssw_5_3_32](https://hub.docker.com/r/cmsopendata/cmssw_5_3_32). 

* __Sending of additional files__: Additional files as the required simulation fragment have to be send with the job, as
curl within the container does not support TLS1.2 required for todays source repositories

* __Access to confdb__: Mounting new /cvmfs repositories from jobs inside a singularity container does often not work due
to unresolved issues of singularity and autofs in CentOS7. Therefore the required confdb has to be 
already contained within the container or transferred with job. The python fragments containing the events have to be patched accordingly.

* __Event numbers__: To avoid issues with the reuse of event numbers between files produces in different jobs, the events number 
has to be set to appropriate values for job to avoid overlaps.

* __Data transfer__: It is prudent to provide alternate storage, in case copying the file to local storage files.

