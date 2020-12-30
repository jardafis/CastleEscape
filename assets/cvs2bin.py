#!/usr/bin/env python

import array,sys,getopt
import numpy as np


def main(argv):
    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
    except getopt.GetoptError:
        print 'test.py -i <inputfile> -o <outputfile>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'test.py -i <inputfile> -o <outputfile>'
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg

    if inputfile == "" or outputfile == "":
        print 'test.py -i <inputfile> -o <outputfile>'
        sys.exit(2)

    outFile = open(outputfile, 'wb')

    with open(inputfile, 'rt') as f:
        lines = f.readlines()
        for line in lines:
            # Remove the CR
            line = line.replace('\n','')
            line = line.replace('-1','255')
            # Split entries by comma
            entries = line.split(',')
            values = [int(x) for x in entries]
            vals = array.array('B', values)
            vals.tofile(outFile)
            print vals

    outFile.close()

if __name__ == "__main__":
   main(sys.argv[1:])
