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
