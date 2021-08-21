const express = require('express');
const fetch = require('node-fetch');
const btoa = require('btoa');
const config = require("./config.json");
const FormData = require("form-data");
const { catchAsync } = require('./utils');

const router = express.Router();

const CLIENT_ID = config.DISCORD_CLIENT_ID;
const CLIENT_SECRET = config.DISCORD_CLIENT_SECRET;
const REDIRECT = encodeURIComponent(config.DISCORD_REDIRECT);

router.get('/login', (req, res) => {
  res.redirect(`https://discord.com/api/oauth2/authorize?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT}&response_type=code&scope=identify%20guilds%20guilds.join`);
});

router.get('/callback', catchAsync(async (req, res) => {
  console.log(req.url);
  console.log(req.params);
  if (!req.query.code) {
    res.redirect(`${config.web_host}/#/register/connections`);
    return;
  }

  const code = req.query.code;
  const creds = btoa(`${CLIENT_ID}:${CLIENT_SECRET}`);

  let data = {
    'client_id': CLIENT_ID,
    'client_secret': CLIENT_SECRET,
    'grant_type': 'authorization_code',
    'code': code,
    'redirect_uri': config.DISCORD_REDIRECT
  }
  params = _encode(data)
  const response = await fetch(`https://discordapp.com/api/oauth2/token`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params
    }
  );
  const json = await response.json();

  console.log(json);
  console.log(json.access_token);
  
  res.redirect(`${config.web_host}/#/register/connections?token=${json.access_token}`);
}));

function _encode(obj) {
  let string = "";

  for (const [key, value] of Object.entries(obj)) {
    if (!value) continue;
    string += `&${encodeURIComponent(key)}=${encodeURIComponent(value)}`;
  }

  return string.substring(1);
}

module.exports = router;