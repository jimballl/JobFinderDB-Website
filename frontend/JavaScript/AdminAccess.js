
/* Functions called in Admin */

// Function to get all past employees at a company
function getPastEmployees() {
    console.log("getPastEmployees in JS");
    var company = document.getElementById("country-input").value;
    console.log("Company: " + company);
    // get command to grab past employees of a company
    fetch(`http://localhost:5000/past_employees?company=${company}`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
        },
    })
    .then(response => {
        if(!response.ok){
            throw new Error(`bad response, status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        console.log("data", data);
        if(!data) return;
        // updating output
        if (data == undefined || data.length == 0) {
            alert("No past employees found for " + company);
        }
        console.log("data", data);
        console.log(document.getElementById("past_employee_input").innerText);
        var employeeNames = data.map(item => "#" + item.ID);
        console.log("employeeNames: " + employeeNames);
        document.getElementById("past_employee_input").innerText = employeeNames.join(", ");        
        // clear original fields
        document.getElementById("country-input").value = "";
    })
    .catch((error) => {
        console.log("past employee filter error:", error)
    });
}

// Function to create a job
function createJob() {
    console.log("createJob in JS");
    var inputNames = ["Job-Title-Input", "Job-Catalogue-Input", "Job-Description-Input", "Work-Setting-Input", "Employment-Type-Input", "Company-Name-Input"];
    var jobData = {};

    inputNames.forEach(function(inputName) {
        jobData[inputName] = document.querySelector(`input[name="${inputName}"]`).value;
    });

    fetch('http://localhost:5000/create_job', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(jobData),
    })
    .then(response => response.json())
    .then(data => {
        console.log('Job created:', data);
        document.getElementById("job_creation_message").innerText = "Job created with ID: " + data.id;
        // clear original fields
        inputNames.forEach(function(inputName) {
            document.querySelector(`input[name="${inputName}"]`).value = "";
        });
    })
    .catch((error) => {
        console.error('Error:', error);
    });
}

// Function to delete a job
function deleteJob() {
    console.log("deleteJob in JS");
    var jobId = document.querySelector('input[name="Job-ID-Input"]').value;

    fetch(`http://localhost:5000/delete_job/${jobId}`, {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json',
        },
    })
    .then(response => response.json())
    .then(data => {
        console.log('Job deleted:', data);
        if (data.message == 'Failed to delete job') {
            alert("No job found with that ID");            
        }
        // clear original field
        document.querySelector('input[name="Job-ID-Input"]').value = "";
    })
    .catch((error) => {
        console.error('Error:', error);
    });
}