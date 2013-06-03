var router = require('urlrouter'),
        path = require('path'),
        filed = require('filed'),
        connect = require('connect'),
        User = require('../models/user');

module.exports = router(function(app){
        app.get('/login.html', connect['static'](__dirname));
        app.post('/login.html', connect.multipart(), function(req, res) {
                console.log('logging in');
                if (req.session.userId) { console.log('Logging in but, but already have userId'); }
                User.findOne({login: req.body.login, password: req.body.password}, function(err, doc){
                        if (err) { res(err); }
                        else {
                                // req.session.userId = doc._id;
                                req.session.userId = doc._id;
                                req.session.save();
                                doc.update({session: req.sessionID}, function(err) {
                                        if (err) {
                                                console.error(err);
                                                res.writeHead(500, 'Server error');
                                                return;
                                        }
                                        console.log('Logged in as ' + doc.name);
                                        res.writeHead(302, {Location: '/selectpc'});
                                        res.end();
                                });
                        }
                });
        });
});
