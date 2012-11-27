#!/usr/bin/env node
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
// My SocketStream app

var http = require('http')
  , ss = require('socketstream');

// Connect to MongoDB
var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/pp');

global.cache = {pc: {} };

// Define a single-page client
ss.client.define('main', {
  view: 'main.html',
  css:  ['libs', 'app.styl', 'css.css', 'forms.css', 'up.css'],
  code: ['libs', 'app', 'system'],
  tmpl: '*'
});

// Serve this client on the root URL
ss.http.route('/', function(req, res){
  res.serveClient('main');
})
var     connect = ss.http.connect,
        MongoStore = require('connect-mongo')(connect);
ss.session.store.use(new MongoStore({db: 'pp'}));
// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-stylus'));

// Use server-side compiled Hogan (Mustache) templates. Others engines available
ss.client.templateEngine.use(require('ss-hogan'));

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env == 'production') ss.client.packAssets();

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(3000);

require('./fixes')

// Start SocketStream
ss.start(server);

//require('node-codein')
