function submitUsernameChange() {
    var oldUsername = document.getElementById("account-name-display").innerText;
    var newUsername = document.getElementById("account-name-input").value;
    console.log("Old Username: " + oldUsername + ", New Username: " + newUsername);
    // checking if oldUsername or newUsername is empty or undefinied
    if (oldUsername == undefined || newUsername == undefined ||
        oldUsername.length == 0 || newUsername.length == 0) {
        alert("Missing old username or new username fields");
        console.log("Missing old username or new username fields");
        return
    }
    console.log("Old Username: " + oldUsername);
    console.log("New Username: " + newUsername);

    // send POST request to server with oldUsername and newUsername
    fetch('http://localhost:5000/UpdateUsername', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            username: oldUsername,
            new_username: newUsername
        }),
    })
    .then(response => {
        if(!response.ok){
            throw new Error(`bad response, status: ${response.status}`);
        }
        return response.json(); // parse the response as JSON
    })
    .then(data => {
        console.log("data", data);
        if(!data) return;
        if(data.result == true){
            console.log("Username Change Successful!");
            document.getElementById("account-name-display").innerText = newUsername;         
        } else {
            console.log("Username Change Failed");
            alert("Username Change Failed - Username may be already taken or invalid.");
        }
    })
    .catch((error) => {
        console.log("Username Change Error:", error)
    });

    //Clearing original fields
    document.getElementById("account-name-input").value = "";
}

function signOut() {
    // Clearing account name display
    document.getElementById("account-name-display").innerText = "";

    // Redirecting to index.html
    window.location.href = "index.html";
}

function deleteAccount() {
    var username = document.getElementById("account-name-display").innerText;

    // checking if username is empty or undefinied
    if (username == undefined || username.length == 0) {
        alert("Missing username field");
        console.log("Missing username field");
        return
    }
    console.log("Username: " + username);

    // send DELETE request to server with username
    fetch(`http://localhost:5000/deleteUser?username=${encodeURIComponent(username)}`, {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json',
        },
    })
    .then(response => {
        if(!response.ok){
            throw new Error(`bad response, status: ${response.status}`);
        }
        return response.json(); // parse the response as JSON
    })
    .then(data => {
        console.log("data", data);
        if(!data) return;
        if(data.result == true){
            console.log("Account Deletion Successful!");
            alert("Account Deletion Successful!");
            window.location.href = "index.html";
        } else {
            console.log("Account Deletion Failed");
            alert("Account Deletion Failed");
        }
    })
    .catch((error) => {
        console.log("Account Deletion Error:", error)
    });
}