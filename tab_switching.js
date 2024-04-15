// Switching between Tabs and hiding the other tabs
function openTab(tabId) {
    var tabInfo;
  
    // Hide all elements with class="tabcontent"
    tabInfo = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabInfo.length; i++) {
      tabInfo[i].style.display = "none";
    }
    
    // Show the specific tab content
    document.getElementById(tabId).style.display = "block";
  }

// Set the default tab on page load
window.onload = function() {
    openTab("jobfinder_content");
};
