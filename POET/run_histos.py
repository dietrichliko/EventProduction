#!/usr/bin/env python3

import argparse
import pathlib

import ROOT  # type: Any

TREES = [
    "myevents",
    "mygenparticle",
    "myelectrons",
    "mymuons",
    "myjets",
    "mymets",
    "myphotons",
    "mypvertex",
    "mytaus",
    "mytracks",
    "mytrigEvent" 
]

def main(input: pathlib.Path, output: pathlib.Path):

    input = ROOT.TFile(f"file:{input_file}", "READ")
    events = input.Get(f"{TREES[0]}/Events")
    friends = []
    for tree in TREES[1:]:
        friends.append(input.Get(f"{tree}/Events"))
        events.AddFriend(friends[-1])

    df = ROOT.RDataFrame(events)
    event_counter = df.Count()

    histos = [
        df.Histo1D(('PV_npvs', 'Number of primary vertices', 50, -0.5, 49.5), 'PV_npvs'),
        df.Histo1D(('PV_npvsGood', 'Number of good primary vertices', 50, -0.5, 49.5), 'PV_npvs'),
    ]

    #ROOT.RDF.RunGraphs(histos+[event_counter])

    print(f'Events processed: {event_counter.GetValue()}')

    output = ROOT.TFile(f'{output_file}', "RECREATE")
    for h1d in histos:
        h1d.Write()
    output.Close()

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("input",help="POET file")
    parser.add_argument('-o', '--output', default="poet_histos.root", help="Histogram output" )
    args = parser.parse_args()

    input_file = pathlib.Path(args.input)
    output_file = pathlib.Path(args.output)

    ROOT.EnableImplicitMT()
    
    main(input_file, output_file)
