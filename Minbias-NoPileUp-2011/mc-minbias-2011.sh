#!/bin/sh -x
#
# Simulate MinBias 7TeV for 2011 using CNS Opendata using cmsconnect
# http://opendata.cern.ch/record/36
# (yilun.wu@Vanderbilt.Edu)
#
# Dietrich.Liko@oeaw.ac.at

FIRST_EVENT=$1
EVENTS=$2
CONDOR_JOB_ID=$3
CONDOR_PROC_ID=$4

FIRST_EVENT=$((FIRST_EVENT + EVENTS*CONDOR_PROC_ID))

# untar the confdb
tar xzvf START53_LV6A1.tgz
find .

# Patch for conditions database

patch_global_tag() {
    sed -f - -i "$1" <<SED_SCRIPT
/^process.GlobalTag = /a process.GlobalTag.connect = cms.string('sqlite_file:${PWD}/START53_LV6A1.db')
/^process.GlobalTag = /a process.GlobalTag.globaltag = 'START53_LV6A1::All'
/^process.GlobalTag = /d
SED_SCRIPT
}

# patch for event number
patch_first_event() {
	sed -f - -i "$1" <<SED_SCRIPT
/^process.source = /a process.source.firstEvent = cms.untracked.uint32($FIRST_EVENT)
SED_SCRIPT
}

# setup CMS environment. CMSSW_VERSION is set by the container

source /opt/cms/cmsset_default.sh
scramv1 project CMSSW ${CMSSW_VERSION}
cd "${CMSSW_VERSION}/src"
eval "$(scramv1 runtime -sh)"

mkdir -p Configuration/GenProduction/python/
mv ../../MinBias_TuneZ2_7TeV_pythia6_cff.py Configuration/GenProduction/python/MinBias_TuneZ2_7TeV_pythia6_cff.py

scram b

cd ../..

# GEN-SIM

cmsDriver.py Configuration/GenProduction/python/MinBias_TuneZ2_7TeV_pythia6_cff.py \
	--mc \
	--eventcontent RAWSIM \
	--customise SimG4Core/Application/reproc2011_2012_cff.customiseG4 \
	--datatier GEN-SIM \
	--conditions START53_LV6A1::All \
	--beamspot Realistic7TeV2011CollisionV2 \
	--step GEN,SIM \
	--python_filename MinBias-Summer11-GENSIM.py \
	--no_exec \
    --fileout MinBias-Summer11-GENSIM.root \
	--number "$EVENTS"

patch_first_event MinBias-Summer11-GENSIM.py
patch_global_tag MinBias-Summer11-GENSIM.py

cat MinBias-Summer11-GENSIM.py

cmsRun MinBias-Summer11-GENSIM.py 

# HLT

cmsDriver.py step1 \
	--mc \
	--step=DIGI,L1,DIGI2RAW,HLT:2011 \
	--datatier GEN-RAW \
	--conditions=START53_LV6A1::All \
	--eventcontent RAWSIM \
	--python_filename MinBias-Summer11-HLT.py \
	--no_exec \
	--filein file:MinBias-Summer11-GENSIM.root \
	--fileout=MinBias-Summer11-HLT.root \
	--number "$EVENTS"

patch_global_tag MinBias-Summer11-HLT.py

cmsRun MinBias-Summer11-HLT.py

# RECO

cmsDriver.py step2 \
	--mc \
	--step RAW2DIGI,L1Reco,RECO,VALIDATION:validation_prod,DQM:DQMOfflinePOGMC \
	--datatier AODSIM,DQM \
	--conditions START53_LV6::All \
	--eventcontent AODSIM,DQM \
	--python_filename MinBias-Summer11-RECO.py \
	--no_exec \
	--filein file:MinBias-Summer11-HLT.root \
	--fileout MinBias-Summer11-RECO.root \
	--number "$EVENTS"

patch_global_tag MinBias-Summer11-RECO.py

cmsRun MinBias-Summer11-RECO.py

xrdcp -np -adler MinBias-Summer11-RECO.root "$OUTPUT_URL/MinBias-Summer11-RECO-${CONDOR_JOB_ID}-${CONDOR_PROC_ID}.root"
if [ $? -ne 0 ]
then
	xrdcp -np -adler MinBias-Summer11-RECO.root "$BACKUP_URL/MinBias-Summer11-RECO-${CONDOR_JOB_ID}-${CONDOR_PROC_ID}.root"
fi
