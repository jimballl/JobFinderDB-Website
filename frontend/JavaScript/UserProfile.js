// Ensures username is looged and can be seend in the homepage
window.onload = function() {
    // ensures we are on the homepage
    if(window.location.pathname.endsWith("homepage.html")){
        var username = localStorage.getItem("username");
        if(username == null){
            window.location.href = "index.html";
        }
        document.getElementById("account-name-display").innerText = username;
    }
}