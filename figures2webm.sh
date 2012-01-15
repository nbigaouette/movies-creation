#!/bin/bash

default_figures_path="figures"
default_figures_pattern="mov%04d"
default_format="png"
default_output_video="output.webm"
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

while getopts hi:p:o:r: name; do
    case $name in
        i)  arg_figures_path="$OPTARG";;
        p)  arg_figures_pattern="$OPTARG";;
        o)  arg_output_video="$OPTARG";;
        r)  arg_resolution="$OPTARG";;
        h)  usage;;
        ?)  usage;;
    esac
done

figures_path="${arg_figures_path-${default_figures_path}}"
figures_pattern="${arg_figures_pattern-${default_figures_pattern}}"
output_video="${arg_output_video-${default_output_video}}"
resolution="${arg_resolution-${default_resolution}}"

cmd1="ffmpeg -i ${figures_path}/${figures_pattern}.png -s ${resolution} -vpre libvpx-720p -b 2000k -pass 1 -an -f webm -y ${output_video}"
cmd2="ffmpeg -i ${figures_path}/${figures_pattern}.png -s ${resolution} -vpre libvpx-720p -b 2000k -pass 2 -an -f webm -y ${output_video}"

echo "$cmd1"
$cmd1
echo "$cmd2"
$cmd2
