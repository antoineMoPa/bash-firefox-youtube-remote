WID=`xdotool search "Mozilla Firefox" | head -1`
xdotool windowactivate --sync $WID

#create tab
xdotool key --clearmodifiers ctrl+t

#go to tab 1
xdotool key --clearmodifiers alt+1

#close current tab
xdotool key --clearmodifiers ctrl+w

sleep 5

#select url bar
xdotool key --clearmodifiers ctrl+l
xdotool key --clearmodifiers BackSpace

sleep 3

#write url
xte "str https://www.youtube.com/watch?v=$1"
xte 'key Return'
