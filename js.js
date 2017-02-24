var input = document.querySelectorAll(".search-field")[0];

var btnSearch = document.querySelectorAll(".search-yt")[0];

btnSearch.onclick = function(){
    var vid = input.value;
    var href = window.location.protocol +
	"//" +
	window.location.host +
	"/searchyt/" + 
	vid;
    
    window.location = href;
};

var current_path = window.location.href.split("/");
var action = current_path[current_path.length - 2];

if(action == "searchyt"){
    var search = current_path[current_path.length - 1]
    input.value = decodeURI(search);
}
