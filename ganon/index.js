
const express = require('express');
const path = require('path');
const fetch = require('node-fetch');
const btoa = require('btoa');
const { catchAsync } = require('./utils.js');
const app = express();

const package = require("./package.json");
const config = require("./config.json");


var admin = require("firebase-admin");

var serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const redirect = encodeURIComponent(config.redirect);

app.listen(config.PORT, () => {
    console.info('Running on port ' + config.PORT);
});

app.use(express.json());

app.get('/', (req, res) => {
    res.status(200).sendFile(path.join(__dirname, 'index.html'));
});

app.get('/ganon/test', (req, res) => {
  res.status(200).send({
    "message": "Ganon v" + package.version
  });
});

app.post('/auth/login', (req, res) => {
  const uid = req.body["id"];
  admin.auth().createCustomToken(uid).then((customToken) => {
    res.status(200).send({
      "token": customToken
    });
  }).catch((error) => {
    console.log('Error creating custom token:', error);
    res.status(500).send({
      "message": "Error creating custom token: " + error
    });
  });
});

app.use('/auth/discord', require('./discord.js'));

app.use((err, req, res, next) => {
    switch (err.message) {
      case 'NoCodeProvided':
        return res.status(400).send({
          status: 'ERROR',
          error: err.message,
        });
      default:
        return res.status(500).send({
          status: 'ERROR',
          error: err.message,
        });
    }
});