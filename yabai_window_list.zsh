#!/bin/zsh

[[ -d "${alfred_workflow_data}" ]] || mkdir "${alfred_workflow_data}"

ps -e -o command | grep '.app' | grep -v 'grep' > ${alfred_workflow_data}/cmds.txt &

query=$1

source app_lists.zsh
# space_id=`yabai -m query --spaces --space | jq -r '.index' `
# app=$(yabai -m query --windows --space $space_id | jq -r ' map(select(.level < 5)) | .[] | {app, id, title} | join(",,,")')
# app=$(yabai -m query --windows | jq -r ' map(select(.level < 5)) | .[] | {app, id, title} | join(",,,")')

IFS="
"
regex='Input Source'

# echo '{"items": [{}'
# for i in `echo "$app"`; do
#     app_name=$(echo $i | grep -Ev "$regex" | awk -F',,,' '{print $1}' | sed 's/iTerm2/iTerm/' | sed -e 's/\\/\\\\\\/g' | sed -e 's/"/\\&/g' | sed -e 's/\r$//g' )
#     app_window=$(echo $i | grep -Ev "$regex" | awk -F',,,' '{print $2}')
#     app_title=$(echo $i | grep -Ev "$regex" | awk -F',,,' '{print $3}' | sed -e 's/\\/\\\\\\/g' | sed -e 's/"/\\&/g' | sed -e 's/\r$//g')

#     if [[ $app_title == "" ]]; then
#         app_title=$app_name
#     fi

#     # icon=`osascript -l JavaScript <<JXA_END 2>/dev/null
# # Application("System Events").applicationProcesses.byName("$app_name").applicationFile().posixPath()
# # JXA_END`

#     if cat ${alfred_workflow_data}/cmds.txt | grep "/Applications/$app_name.app" | grep -v 'grep' >> /dev/null ; then
#         icon="/Applications/$app_name.app"
#     else
#         icon=`cat ${alfred_workflow_data}/cmds.txt | grep "$app_name.app" | uniq | awk -F'.app' '{print $1".app"}' | head -n 1`
#     fi
#     cat <<EOF
#   ,{
#      "uid": "$app_name",
#      "title": "$app_title",
#      "subtitle": "$app_name",
#      "arg": "$app_window",
#      "icon": { "type": "fileicon", "path": "$icon" },
#      "match": "$app_name $app_title",
#      "variables": { "app_name": "$app_name", "window_name": "$app_title" }
#   }
# EOF


# done
# echo ']}'

# fzf search

cat ${alfred_workflow_data}/apps.txt        \
  | fzf +s -f "$query"  \
  | head -n30          \
  > ${alfred_workflow_data}/matches.txt


echo '{"items": [{}'
while IFS='' read -r i || [ -n "${i}" ]; do

    app_name=$(echo $i | grep -Ev "$regex" | awk -F',,,' '{print $1}' | sed 's/iTerm2/iTerm/' | sed -e 's/\\/\\\\\\/g' | sed -e 's/"/\\&/g' | sed -e 's/\r$//g' )
    app_window=$(echo $i | grep -Ev "$regex" | awk -F',,,' '{print $2}')
    app_title=$(echo $i | grep -Ev "$regex" | awk -F',,,' '{print $3}' | sed -e 's/\\/\\\\\\/g' | sed -e 's/"/\\&/g' | sed -e 's/\r$//g')

    re='^[0-9]+$'
    if [[ $query =~ $re ]] ; then
	    app_window="move_to_space|$query|$app_window"
    fi

    if [[ $app_title == "" ]]; then
        app_title=$app_name
    fi

n    # icon=`osascript -l JavaScript <<JXA_END 2>/dev/null
# Application("System Events").applicationProcesses.byName("$app_name").applicationFile().posixPath()
# JXA_END`

    if cat ${alfred_workflow_data}/cmds.txt | grep "/Applications/$app_name.app" | grep -v 'grep' >> /dev/null ; then
        icon="/Applications/$app_name.app"
    else
        icon=`cat ${alfred_workflow_data}/cmds.txt | grep "$app_name.app" | uniq | awk -F'.app' '{print $1".app"}' | head -n 1`
    fi
    cat <<EOF
  ,{
     "uid": "$app_name",
     "title": "$app_title",
     "subtitle": "$app_name",
     "arg": "$app_window",
     "icon": { "type": "fileicon", "path": "$icon" },
     "match": "$app_name $app_title",
     "variables": { "app_name": "$app_name", "window_name": "$app_title" }
  }
EOF
done < ${alfred_workflow_data}/matches.txt
echo ']}'
