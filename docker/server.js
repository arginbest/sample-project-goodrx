'use strict';

const express = require('express');
const PORT = 8080;
const HOST = '0.0.0.0';

const app = express();
app.use(express.json({
  inflate: true,
  limit: '100kb',
  strict: true,
  type: 'application/json'
}));

// This is for pretty output. I'd comment this out for production.
app.set('json spaces', 4);

app.post('/builds', (req, res) => {

  var data = req.body.jobs["Build base AMI"]["Builds"];
  var dataLength = data.length;
  var latestDate = 0;
  var latestOutput = "null null null null";

      for (var i = 0; i < dataLength; i++) {
        if (data[i]["build_date"] > latestDate) {
            latestDate = data[i]["build_date"];
            latestOutput = data[i]["output"];
        }
    }

  res.json({ "latest": { "build_date": latestDate, "ami_id": latestOutput.split(' ')[2], "commit_hash": latestOutput.split(' ')[3] } });
});

// Adding a GET endpoint so Node returns the proper response code. 
app.get('/builds', (req, res) => {
  res.status(405);
  res.send("GET not allowed");
});

// For the ELB healthcheck
app.get('/status', (req, res) => {
  res.status(200);
  res.send("ok");
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
