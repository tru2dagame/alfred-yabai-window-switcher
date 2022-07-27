#!/bin/zsh

space_id=`yabai -m query --spaces --space | jq -r '.index' `
current_window=`yabai -m query --windows --window | jq -r '.id'`

window_id=`yabai -m query --windows --space $space_id | jq -r ' map(select(.level < 5)) | sort_by(.id) | reverse | map(select(.id < '$current_window')) | .[0] | {app, id} | join(",")'`
if [ $window_id = ',' ]; then
    window_id=`yabai -m query --windows --space $space_id | jq -r ' map(select(.level < 5)) | sort_by(.id) | reverse | .[0] | {app, id} | join(",")'`
fi
yabai -m window --focus `echo $window_id | awk -F',' '{print $2}'`
