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
    if [ "$1" == "yt" ]; then
		echo "Listening: "$(decode $2)
        nohup bash firefox-remote.sh $2 > /dev/null &
		cat index.html
	else
		
		cat index.html
    fi
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
                echo "HTTP/1.1 200 OK"
                echo "Content-type: text/html"
                echo "Content-Encoding: UTF-8"
                
                MESSAGE="SUCCESS "$(date)$'\n'
                
                url1=$(echo $url | cut -d "/" -f2)
                url2=$(echo $url | cut -d "/" -f3)
                url3=$(echo $url | cut -d "/" -f3)
                url4=$(echo $url | cut -d "/" -f3)
                
                MESSAGE=$(route $url1 $url2 $url3 $url4)

                LCOUNT=$(echo $MESSAGE | wc -c)
                
                echo "Content-Length: "$LCOUNT
                echo "Connection: close"
                echo ""
                
                echo $MESSAGE
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
    nc -l 4000 0< <(fn_out) 1> >(fn_in)
    serve
}

serve
