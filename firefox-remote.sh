WID=`xdotool search "Mozilla Firefox" | head -1`
xdotool windowactivate --sync $WID

#close current window
xdotool key --clearmodifiers ctrl+t

xdotool key --clearmodifiers alt+1
xdotool key --clearmodifiers ctrl+w

sleep 5

xdotool key --clearmodifiers ctrl+l
xdotool key --clearmodifiers BackSpace

sleep 3

xte "str https://www.youtube.com/results?search_query=$1"
xte 'key Return'

sleep 15

xte 'key Return'

sleep 5

xte 'key Tab'

xte 'mousemove 200 300'
xte 'mouseclick 1'
