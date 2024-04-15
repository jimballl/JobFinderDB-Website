const cors = require('cors');
const express = require('express');
const app = express();

app.use(cors());
app.use(express.json())

// Allow for posting to the server "CheckUser" endpoint
app.get('/checkUser', (req, res) => {
    const username = req.query.username;
    const password = req.query.password;

    console.log(res.query);
    res.json();
});

app.post('/signUp', (req, res) => {
    const { username, password, name, sex, years_of_experience } = req.body;

    res.json({username, password, name, sex, years_of_experience});
})

app.listen(5000, () => {
    console.log('Server is running on port 5000');
});