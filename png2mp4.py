#!/usr/bin/python
# -*- coding: utf-8 -*-

# ****************************************************************************************************************************************************
# http://docs.python.org/library/optparse.html
from optparse import OptionParser
parser = OptionParser()

parser.add_option("-i", "--input",      type=str,            dest="input",      default="figures/vpython/latest/png",       help="Input path to PNGs files [default: %default]")
parser.add_option("-o", "--output",     type=str,            dest="output",     default="figures/movie.mp4",                help="Output path [default: figures/]")
parser.add_option("-r", "--resolution", type=str,            dest="resolution", default="1728x1080",                        help="Resolution [default: %default]")

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

print "Converting PNGs from", png_folder, "to", movie, "at", options.resolution

resolution = options.resolution.split("x")

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

# Simple
command = "ffmpeg -i " + input_pngs + " -an -vcodec libx264 -vpre fastfirstpass -b 512k -bt 512k -threads 0 -s " + options.resolution + " " + movie
#command = "ffmpeg -i figures/vpython/latest/png/povray_%010d.png -pass 1 -an -vcodec libx264 -vpre fastfirstpass -vpre ipod320 -b 512k -bt 512k -threads 0 -f rawvideo -y /dev/null && ffmpeg -i myfile.avi -pass 2 -acodec copy -vcodec libx264 -vpre hq -vpre ipod320 -b 512k -bt 512k -threads 0 figures/out.mp4"

print command
pid = subprocess.Popen(shlex.split(command))
pid.wait()
print "Done"

