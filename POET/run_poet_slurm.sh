#!/bin/bash -x
#SBATCH --cpus-per-task=1
#SBATCH --job-name=run_poet
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err
#SBATCH --time=6:00:00

# pass the directory of input files to python using env variable
export SOURCEDIR=$1

export X509_USER_PROXY=$HOME/private/proxy
voms-proxy-info

if [ -n "$SLURM_JOB_ID" ];  then
    # check the original location through scontrol and $SLURM_JOB_ID
    SCRIPTDIR=$(dirname "$(scontrol show job "$SLURM_JOB_ID" | awk '/Command=/{print substr($1,9)}')")
    WORKDIR="$SCRATCHDIR/work-$SLURM_JOB_ID"
else
    # otherwise: started with bash. Get the real location.
    SCRIPTDIR=$(dirname "$(realpath "$0")")
    WORKDIR="/afs/cern.ch/work/l/liko/work-$$"
fi
mkdir "$WORKDIR"
cd "$WORKDIR" || exit 1

git clone --depth 1 --branch master https://github.com/cms-legacydata-analyses/PhysObjectExtractorTool.git
cp  "$SCRIPTDIR/poet_minbias_cfg.py" .

sif="/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmsopendata/cmssw_5_3_32:latest"

unset SCRAM_ARCH
singularity run -H $WORKDIR -B /eos "$sif" <<EOF
    pwd
    set -x
    mv ../../PhysObjectExtractorTool ../../poet_minbias_cfg.py .
    scram b
    cmsRun poet_minbias_cfg.py False False
EOF


