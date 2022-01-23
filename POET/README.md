# Extact an Ntuple from the simulated data

The [Physics Object Extractor Tool](https://github.com/cms-legacydata-analyses/PhysObjectExtractorTool) can 
be used to provide relevant data from the AOD data for further analysis.

## Usage instructions

### Install appropriate CMSSW [Docker container](https://opendata.cern.ch/docs/cms-guide-docker)

In case you have access to a computing site that provides [Singularity](https://sylabs.io) and [CVMFS](https://cernvm.cern.ch/), 
the container can be started

```bash
singularity run /cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmsopendata/cmssw_5_3_32:latest /bin/bash
```

Note that the entrypoint script will create a ```CMSSW_5_3_32/src``` subdirectory and configure the environment.

### Poet configuration file

Copy the file from the repo

Following modifications

Configure input files. In the example input files are read from a directory of EOS and provided as a list
of urls to CMSSW.
```python
sourceFiles = [ 'root://eos.grid.vbc.ac.at/%s/%s' % (sourcePath, name) for name in os.listdir(sourcePath) ]
process.source = cms.Source("PoolSource", fileNames = cms.untracked.vstring(*sourceFiles))
```

### Uncomment  confdb

Inside the container DB is available locally

### Set maximum number of events

Max number of events to -1
```python
process.maxEvents = cms.untracked.PSet( input = cms.untracked.int32(-1) )
```

### Suppress duplicate event warning, if required 
```python
process.source.duplicateCheckMode = cms.untracked.string('noDuplicateCheck')
```

## Run on the simulated data

An example is given how to run on a sample of data in a subdirectory. You have to adapt storage location 
and batch system to your site.

```bash
poet_minbias_cfg.py
run_poet_slurm.sh
```

## Produce histograms

A script is provided as example how to produce histograms using ROOT DataFrames.

It can be run using a modern ROOT version, for example from the [Docker container](https://hub.docker.com/r/rootproject/root) provided by the 
ROOT team.

```bash
singularity run /cvmfs/unpacked.cern.ch/registry.hub.docker.com/rootproject/root:6.24.06-centos7 run_histos.py <inputfile>
```


