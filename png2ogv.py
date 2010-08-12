#!/usr/bin/python
# -*- coding: utf-8 -*-

# ****************************************************************************************************************************************************
# http://docs.python.org/library/optparse.html
from optparse import OptionParser
parser = OptionParser()

parser.add_option("-i", "--input",      type=str,            dest="input",      default="figures/vpython/latest/png",       help="Input path to PNGs files [default: %default]")
parser.add_option("-o", "--output",     type=str,            dest="output",     default="figures/movie.ogv",                help="Output path [default: figures/]")
parser.add_option("-q", "--quality",    type=str,            dest="quality",    default="10",                               help="Movie quality (0=worst, 10=best) [default: %default]")
parser.add_option("-p", "--pass",       type=int,            dest="npass",      default=1,                                  help="Number of pass (1 or 2) [default: %default]")

(options, args) = parser.parse_args()
# ****************************************************************************************************************************************************

import os, glob, re, sys
import subprocess, shlex

png_folder = os.path.normpath(options.input)

# Get all PNG files
pngfiles = glob.glob(os.path.join(png_folder, "*.png"))
pngfiles.sort()

if (len(pngfiles) == 0):
    if (os.path.split(png_folder) != "png"):
        png_folder = os.path.join(options.input, "png")
        pngfiles = glob.glob(os.path.join(png_folder, "*.png"))
        pngfiles.sort()

        if (len(pngfiles) == 0):
            print "ERROR: No png files found in '" + png_folder + "'! Exiting."
            sys.exit(1)

movie = os.path.normpath(options.output)

print "Converting PNGs from", png_folder, "to", movie, "at quality", options.quality, "with", options.npass, "pass"

try:
    os.makedirs(os.path.dirname(movie))
except OSError:
    #print "Folder already exist."
    pass

#framePattern = re.compile('([0-9]*)')
#framePattern = re.compile('(0000000001)')
#framePattern = re.compile('([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])')
framePattern = re.compile('([0-9][0-9]*)')
#framePattern = re.compile('(\d{10})')
n_string = framePattern.search(pngfiles[0]).group(1)
n = len(n_string)

input_pngs = pngfiles[0].replace(n_string, "%0" + str(n) + "d")

if (options.npass == 1):
    command = "png2theora --video-quality " + options.quality + " \"" + input_pngs + "\" --output " + movie

    print command
    pid = subprocess.Popen(shlex.split(command))
    pid.wait()
    print "Done"
elif (options.npass == 2):
    command1 = "png2theora --video-quality " + options.quality + " --output " + movie.replace(".ogv", ".tmp") + " --first-pass "  + input_pngs
    command2 = "png2theora --video-quality " + options.quality + " --output " + movie + " --second-pass " + movie.replace(".ogv", ".tmp")
    #command1 = "png2theora --video-quality " + options.quality + " --output " + movie.replace(".ogv", ".tmp") + " --first-pass "  + input_pngs

    print "WARNING: Two pass is broken. Trying anyway..."
    print "First pass:"
    print "  " + command1
    pid = subprocess.Popen(shlex.split(command1))
    pid.wait()
    print "Second pass:"
    print "  " + command2
    pid = subprocess.Popen(shlex.split(command2))
    pid.wait()
    print "Done"
else:
    print "Wrong number of pass!"
    print "Possible: 1 or 2 (given: " + str(options.npass) + ")"













