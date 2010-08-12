#!/bin/bash

if [[ "${1/*./}" != "ogv" ]]; then
    echo "Argument must be an .ogv file (\"$1\" given)"
    exit
fi

ogv_file="${1}"
mp4_file="${1/.ogv/.mp4}"


cmd_ffmpeg="ffmpeg -i ${ogv_file} -vcodec libx264 -threads 0 ${mp4_file}"
#echo "cmd_ffmpeg:"
#echo "    ${cmd_ffmpeg}"

# x264 --help
cmd_x264="x264 -o ${mp4_file} ${ogv_file}"
echo "cmd_x264"
echo "    ${cmd_x264}"
${cmd_x264}
