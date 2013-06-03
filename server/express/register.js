// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
var     Invite = require('../models/invite'),
        User = require('../models/user');

var     router = require('urlrouter'),
        path = require('path'),
        filed = require('filed'),
        connect = require('connect');


function getInvite(req, res, next) {
        Invite.findById(req.params.id, function(err, invite){
                if (err) { return next(err); }
                if (invite.user) {
                        next(new Error("Invite already used by "+ invite.user));
                } else {
                        req.invite = invite;
                        next();
                }
        });
}

function sendfile(file) {
        return function(req,res) {
                req.pipe(filed(path.resolve(__dirname, file))).pipe(res);
        };
}

function adduser (req, res) {
        console.log('Adding user');
        var user = new User({login: req.body.login, password: req.body.password});
        user.save(function(err, doc) {
                if (err) { 
                        console.error(err);
                        res.writeHead(500, err);
                        return res.end();
                }
                req.invite.user = doc;
                req.invite.save();
                console.log('added user');
                // req.pipe(filed(__dirname + 'success.html')).pipe(res);
                // sendfile('success.html')(req,res);
                res.writeHead(302, {Location: '/selectpc'});
                res.end();
        });
}

function api(router) {
        router.get('/registration/:id', getInvite, sendfile('form.html'));
        router.post('/registration/:id', getInvite, connect.multipart(), adduser);
}

module.exports = router(api);
