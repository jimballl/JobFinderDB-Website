/* functions calledin User */

// gets all companies in a country
function getCompaniesInCountry() {
    console.log("companyCountryFilter");
    var country = document.getElementById("country-input").value;
    console.log("Country: " + country);
    // get command to grab companies in a country
    fetch(`http://localhost:5000/companies_in_country?country=${country}`, {
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
            alert("No companies found in " + country);
        }
        console.log("data", data);
        console.log(document.getElementById("company_name_input").innerText);
        var companyNames = data.map(item => item.name);
        document.getElementById("company_name_input").innerText = companyNames.join(", ");        // clear original fields
        document.getElementById("country-input").value = "";
    })
    .catch((error) => {
        console.log("country filter error:", error)
    });
}

// returns employess in a company that have a salary within the given range
function getCompaniesWithinSalary() {
    var minSalary = document.getElementById("min-salary-input").value;
    var maxSalary = document.getElementById("max-salary-input").value;
    console.log("minSalary: " + minSalary + ", maxSalary: " + maxSalary);
    // checking if minSalary or maxSalary is empty or undefined
    if (minSalary == undefined || maxSalary == undefined ||
            minSalary.length == 0 || maxSalary.length == 0) {
        alert("Missing minSalary or maxSalary fields");
        console.log("Missing minSalary or maxSalary fields");
        return;
    }
    if (minSalary < 0 || maxSalary < 0 || minSalary > maxSalary) {
        alert("Invalid salary range");
        return;
    }
    console.log("Min Salary: " + minSalary + ", Max Salary: " + maxSalary);
    // get command to grab companies within salary range
    fetch(`http://localhost:5000/companies_within_salary?min_salary=${minSalary}&max_salary=${maxSalary}`, {
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
            document.getElementById("company_name_input_salary").innerText = "No jobs found within salary range";
        } else {
            var companyNames = data.map(item => item.job_title + " @ " + item['Company Name']);
            document.getElementById("company_name_input_salary").innerText = companyNames.join(", ");
        }
        console.log("data", data);
        console.log(document.getElementById("company_name_input").innerText);

        // clear original fields
        document.getElementById("min-salary-input").value = "";
        document.getElementById("max-salary-input").value = "";
    })
    .catch((error) => {
        console.log("salary filter error:", error)
    });
}

