function submitSignIn() {
    var username = document.getElementById("username_input").value;
    var password = document.getElementById("password_input").value;

    // checking if username or password is empty or undefinied
    if (username == undefined || password == undefined ||
            username.length == 0 || password.length == 0) {
        alert("Missing username or password fields");
        console.log("Missing username or password fields");
        return
    }
    console.log("Username: " + username);
    // get command to server with username and password
    fetch(`http://localhost:5000/checkUser?username=${encodeURIComponent(username)}&password=${encodeURIComponent(password)}`, {
        method: 'GET',
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
        console.log("data", data.message);
        if(!data) return;
        if(data.result == -1) {
            alert(data.message)
        } else if (data.result == 1) {
            alert(data.message)
        }
    })
    .catch((error) => {
        console.log("SignIn Error:", error)
    });

    //Clearing original fields
    document.getElementById("username_input").value = "";
    document.getElementById("password_input").value = "";

}

function submitSignUp() {
    var username = document.getElementById("username_input_signup");
    var name = document.getElementById("name_input_signup");
    var password = document.getElementById("password_input_signup");
    var sex = document.getElementById("sex_input");
    var years_of_experience = document.getElementById("YOE_input");
    // Generating random SSN values to avoid users giving out their real SSN
    var ssn = Math.floor(Math.random() * 20000)

    variables = [username, name, password, sex, years_of_experience];
    // checking if any of the variables are empty
    variables.forEach(v => {
        if (v.value == undefined || v.value.length == 0) {
            alert("Missing a field");
            return;
        }
    })
    // fetching the data to the server in a post command
    fetch('http://localhost:5000/signUp', {
        method: 'Post',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({username, password, name, sex, years_of_experience})
    })
    .then(response => {
        if(!response.ok){
            throw new Error(`bad response, status: ${response.status}`);
        }
        return response.json(); // ensures the next .then call used
    })
    .then(data => {
        if(data) {
            console.log('Success:', data);
            alert("Sign Up Successful!");
        } else {
            console.log("No data found")
        }
    })
    .catch((error) => {
        console.log("SignUp Error:", error)
    })

    variables.forEach(v => (
        v.value = ""
    ))
}