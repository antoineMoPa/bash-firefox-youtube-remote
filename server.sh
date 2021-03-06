#!/bin/bash

rm thepipe
mkfifo thepipe

function decode {
    # decode url symbols such as %20
    # from: http://unix.stackexchange.com/questions/159253/decoding-url-encoding-percent-encoding
    urlhuman=$(echo $1 | sed 's@+@ @g;s@%@\\x@g' | xargs -0 printf "%b")
	echo $urlhuman
}

function route {
	if [ "$1" == "js.js" ]; then
		reply "200 OK" "text/javascript" < <(cat js.js)
	elif [ "$1" == "css.css" ]; then
		reply "200 OK" "text/css" < <(cat css.css)
	elif [ "$1" == "yt" ]; then
		nohup bash firefox-remote.sh $2 > /dev/null &
		reply "200 OK" "text/html" < <(cat index.html)
	elif [ "$1" == "searchyt" ]; then
		# find search results
		# todo: bash script injection here with $2
		SEARCH_URL="https://www.youtube.com/results?search_query=$2"
		VIDSDATA=$(curl "$SEARCH_URL")
		
		VIDSLIST=$(echo "${VIDSDATA}" |\
						  grep "/watch?v=" |\
						  grep -o "watch?v=[A-Za-z0-9_]\{11,11\}" |\
						  sed "s/\s*watch?v=\s*//g" |\
						  uniq |\
						  sed "s/\s//g" |\
						  uniq)
		
		while read vidid; do
			TITLE=$(echo "${VIDSDATA}" | grep "$vidid" | grep -v "<button" |  sed "s/title=\"\([^\"]*\)/\nTHETITLE=\1\n/" | grep THETITLE | sed "s/THETITLE=//g")
			VIDSHTML="${VIDSHTML}"'\n'"<div class='vid-result'>\
<a class='one-vid' href='/yt/$vidid'>\
<img src='https://i.ytimg.com/vi/$vidid/default.jpg'>\
<span class='vidtitle'>$TITLE<\/span>\
</a>\
<\/div>"
			
		done < <( echo "$VIDSLIST" )
   		
		# put on one line
		VIDS=$(echo $VIDSHTML)
		OUTPUT=$(cat index.html) # | sed 's#BASHvideoSearchResults#'"$VIDS"'#g')
		reply "200 OK" "text/html" < <(echo "${OUTPUT}")
		
	else
		reply "200 OK" "text/html" < <(cat index.html)
    fi
}

# give http reply
# $1 code
# $2 content type
# stdin message
function reply {
	echo "HTTP/1.1 $1"
    echo "Content-type: $2"
    echo "Content-Encoding: UTF-8"

	MESSAGE=""

	while read line; do
		MESSAGE="${MESSAGE}""${line}"$'\r\n'
	done

    LCOUNT=$(echo "$MESSAGE" | wc -c)
	
    echo "Content-Length: "$LCOUNT
    echo "Connection: close"
    echo ""
    
    echo "${MESSAGE}"
}

function fn_out {
    REQ=""
    line=""
    lcount=0
    
    url=""
    
    while true;
    do
        if read line; then
            REQ="${REQ}${line}"
            
            if [ -z "${line}" ]; then
                
                url1=$(echo $url | cut -d "/" -f2)
                url2=$(echo $url | cut -d "/" -f3)
                url3=$(echo $url | cut -d "/" -f3)
                url4=$(echo $url | cut -d "/" -f3)

				# route and reply
                route $url1 $url2 $url3 $url4 

                return
            else
                lcount=$(($lcount+1))
                
                line=$(echo $line| sed "s/\r//g")
                
                if [ $lcount = 1 ]; then 
                    # find path
                    # (by removing GET/POST and HTTP)
                    url=$(echo $line | sed "s/GET \|POST //g" | sed "s/ HTTP\/[0-9\.]*//g")
                    
                fi
            fi
        fi
    done < thepipe
}

function fn_in {
    while read -r line;
    do
        line=$(echo $line | sed "s/^\s$/\n/g")
        
        if [ -z "$line" ]; then
            echo "" >> thepipe
        else
            echo $line > thepipe
        fi
        
    done
}

function serve {
    echo "listening at port 4000"
    nc -l -p 4000 0< <(fn_out) 1> >(fn_in)
    serve
}

serve
