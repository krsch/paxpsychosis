#!/usr/bin/env node
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
// My SocketStream app

var http = require('http')
  , redirect = require('connect-redirection')
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
ss.client.define('dialogeditor', {
  view: 'dialogeditor.html',
  css:  ['libs', 'dialogeditor.css'],
  code: ['libs', 'dialogeditor', 'system'],
  tmpl: '*'
});
ss.client.define('selectpc', {
  view: 'selectpc.html',
  css:  ['libs', 'selectpc.styl'],
  code: ['libs', 'selectpc', 'system'],
  tmpl: '*'
});

// Serve this client on the root URL
ss.http.route('/', function(req, res){
        var User = require('./server/models/user');
        if (!req.session) { return res.redirect('/login.html'); }
        // req.session.userId ||= User.by_sid(req.sessionID);
        if (!req.session.userId) { return res.redirect('/login.html'); }
        // req.session.pc_id ||= User.getPc(req.session.userId);
        if (!req.session.pc_id) { return res.redirect('/selectpc'); }
        res.serveClient('main');
});
ss.http.route('/dialogeditor', function(req, res){
  res.serveClient('dialogeditor');
});
ss.http.route('/selectpc', function(req, res){
        if (req.session && req.session.userId) { res.serveClient('selectpc'); } 
        else { return res.redirect('/login.html'); }
});
ss.http.route('/logout', function(req, res){
        req.session.destroy();
        res.redirect('/login.html');
});
ss.http.route('/login.html', function(req,res){
        require('./server/express/login.js')(req,res,function(err){
                if (err) {
                        console.error(err);
                        res.writeHead(500, 'Server error');
                        res.end();
                }
        });
});

var     connect = ss.http.connect,
        MongoStore = require('connect-mongo')(connect);
ss.session.store.use(new MongoStore({db: 'pp'}));
ss.http.middleware.prepend(redirect());
ss.http.middleware.append(require('./server/express/register.js'));
// ss.http.middleware.append(require('./server/express/login.js'));
// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-stylus'));

// Use server-side compiled Hogan (Mustache) templates. Others engines available
ss.client.templateEngine.use(require('ss-hogan'));
ss.client.templateEngine.use(require('ss-clientjade'),'/jade', {debug: true});

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env == 'production') ss.client.packAssets();

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(3000);

require('./fixes');

// Start SocketStream
ss.start(server);

//require('node-codein')
