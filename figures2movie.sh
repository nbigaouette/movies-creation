#!/bin/bash

default_figures_path="figures"
default_figures_pattern="mov%04d"
default_figure_format="png"
default_video_filename="output"
default_fps="24"
default_video_format="webm"
default_resolution="NoChange"
default_h264_profile="max"

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
    echo "-f <figure_format>            Figure format."
    echo "                                  DEFAULT: ${default_figure_format}"
    echo "-a <fps>                       Frame per second (frame rate)."
    echo "                                  DEFAULT: ${default_fps}"
    echo "-v <video_format>             Video format."
    echo "                                  Available: webm, ogv, mp4 (h264)"
    echo "                                  DEFAULT: ${default_video_format}"
    echo "-o <output file>              Output file."
    echo "                                  DEFAULT: ${default_video_filename}"
    echo "-r <resolution>               Video resolution. Note that if the aspect ratio"
    echo "                              is different from the figures the video will look distorted."
    echo "                                  DEFAULT: ${default_resolution}"
    echo "-q <profile>                  x264's profile (only used with 'mp4' video format)"
    echo "                                  DEFAULT: ${default_h264_profile}"
    echo ""
    exit
}

if [[ "x$@" == "x" || "x$@" == "x-h" || "x$@" == "x--help" ]]; then
    usage
fi

while getopts hi:p:f:a:v:o:r:q: name; do
    case $name in
        i)  arg_figures_path="$OPTARG";;
        p)  arg_figures_pattern="$OPTARG";;
        f)  arg_figure_format="$OPTARG";;
        a)  arg_fps="$OPTARG";;
        v)  arg_video_format="$OPTARG";;
        o)  arg_video_filename="$OPTARG";;
        r)  arg_resolution="$OPTARG";;
        q)  arg_profile="$OPTARG";;
        h)  usage;;
        ?)  usage;;
    esac
done

figures_path="${arg_figures_path-${default_figures_path}}"
figures_pattern="${arg_figures_pattern-${default_figures_pattern}}"
figure_format="${arg_figure_format-${default_figure_format}}"
video_fps="${arg_fps-${default_fps}}"
video_filename="${arg_video_filename-${default_video_filename}}"
video_format="${arg_video_format-${default_video_format}}"
profile="${arg_profile-${default_h264_profile}}"

video_filename=${video_filename/.*/}.${video_format}
if [[ "${figures_path#${figures_path%?}}x" != "/x" ]]; then
    figures_path="${figures_path}/"
fi

resolution_arg=""
if [[ "${arg_resolution}x" != "x" ]]; then
    resolution_arg="-s ${arg_resolution}"
fi

# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export FFMPEG_DATADIR=${script_dir}/ffmpeg-presets/

# http://blog.pcode.nl/2010/10/17/encoding-webm-using-ffmpeg/
# http://rob.opendot.cl/index.php/useful-stuff/ffmpeg-x264-encoding-guide/
case ${video_format} in
    webm)   commands=(
                "ffmpeg -an -i ${figures_path}${figures_pattern}.${figure_format} ${resolution_arg} -r ${video_fps} -vpre libvpx-720p -b:v 2000k -pass 1 -f webm -y ${video_filename}"
                "ffmpeg -an -i ${figures_path}${figures_pattern}.${figure_format} ${resolution_arg} -r ${video_fps} -vpre libvpx-720p -b:v 2000k -pass 2 -f webm -y ${video_filename}"
            );;
    ogv)    commands=(
                "ffmpeg -an -i ${figures_path}${figures_pattern}.${figure_format} ${resolution_arg} -r ${video_fps} -vcodec libtheora -b:v 2000k ${video_filename}"
            );;
    mp4)    commands=(
                "ffmpeg -an -i ${figures_path}${figures_pattern}.${figure_format} -vcodec libx264 ${resolution_arg} -threads 0 -r ${video_fps} -vpre ${profile} -crf 25 ${video_filename}"
            );;
esac


for cmd in "${commands[@]}"; do
    echo $cmd
    $cmd || exit
done


