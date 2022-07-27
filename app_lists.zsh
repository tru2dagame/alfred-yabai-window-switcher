#!/usr/bin/env zsh

if [[ "$query" =~ ^\`.* || "$query" =~ .*\`$ ]]; then
    yabai -m query --windows | jq -r ' map(select(.level < 5)) | .[] | {app, id, title} | join(",,,")' > ${alfred_workflow_data}/apps.txt

    # query="${query:1}"
    # query=${query%?}
    query=$(echo $query | sed 's/`//g')
else
    space_id=`yabai -m query --spaces --space | jq -r '.index' `
    yabai -m query --windows --space $space_id | jq -r ' map(select(.level < 5)) | .[] | {app, id, title} | join(",,,")' > ${alfred_workflow_data}/apps.txt
fi
