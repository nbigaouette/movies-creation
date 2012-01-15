#!/bin/bash

default_figures_path="figures"
default_figures_pattern="mov%04d"
default_format="png"
default_output_video="output.mp4"
default_resolution="800x600"

function usage()
{
    echo ""
    echo "Encode a WebM video from a set of figures, using two-pass (high quality) ffmpeg."
    echo "Usage:"
    echo ""
    echo "${0} [OPTIONS]"
    echo ""
    echo "Options:"
    echo "-i <path/to/figures>          Path to figures' location."
    echo "                                  DEFAULT: ${default_figures_path}"
    echo "-p <figure pattern>           Pattern to match figures."
    echo "                                  DEFAULT: ${default_figures_pattern}"
    echo "-f <format>                   Figure format."
    echo "                                  DEFAULT: ${default_format}"
    echo "-o <output file>              Output file."
    echo "                                  DEFAULT: ${default_output_video}"
    echo "-r <resolution>               Video resolution. Note that if the aspect ratio"
    echo "                              is different from the figures the video will look distorted."
    echo "                                  DEFAULT: ${default_resolution}"
    echo ""
    exit
}

if [[ "x$@" == "x" || "x$@" == "x-h" || "x$@" == "x--help" ]]; then
    usage
fi

while getopts hi:p:f:o:r: name; do
    case $name in
        i)  arg_figures_path="$OPTARG";;
        p)  arg_figures_pattern="$OPTARG";;
        f)  arg_format="$OPTARG";;
        o)  arg_output_video="$OPTARG";;
        r)  arg_resolution="$OPTARG";;
        h)  usage;;
        ?)  usage;;
    esac
done

figures_path="${arg_figures_path-${default_figures_path}}"
figures_pattern="${arg_figures_pattern-${default_figures_pattern}}"
format="${arg_format-${default_format}}"
output_video="${arg_output_video-${default_output_video}}"
resolution="${arg_resolution-${default_resolution}}"

# http://rob.opendot.cl/index.php/useful-stuff/ffmpeg-x264-encoding-guide/
cmd="ffmpeg -i ${figures_path}/${figures_pattern}.${format} -an -vcodec libx264 -s ${resolution} -threads 0 -vpre slow -crf 25 ${output_video}"

echo "$cmd"
$cmd

