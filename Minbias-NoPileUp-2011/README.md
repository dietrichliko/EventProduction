# How to submit

Connect to cmsconnect 
```bash
ssh -l dietrich.liko login-el7.uscms.org
```

Setup proxy certificate
```bash
voms-proxy-init -voms cms -rfc -valid 192:0
```

Clone repo
```bash
git clone https://gitlab.cern.ch/....
cd EventProduction/MinBias-NoPileUp-2011
```

Download production fragment for the process
```bash
curl  -sO https://raw.githubusercontent.com/cms-sw/genproductions/V01-00-46/python/MinBias_TuneZ2_7TeV_pythia6_cff.py
```

Create tar file from the required confdb
```bash
tar czvf START53_LV6A1.tgz /cvmfs/cms-opendata-conddb.cern.ch/START53_LV6A1 /cvmfs/cms-opendata-conddb.cern.ch/START53_LV6A1.db
```

Change the site and and storage url in ```mc-minbias-2011.job``` according to your environment. Set the required number of events per
process and the required number of processes.

Submit jobs
```bash
condor_submit mc-minbias-2011.job
```

Job Status
```
condor_q
```