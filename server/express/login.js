var router = require('urlrouter'),
        path = require('path'),
        filed = require('filed'),
        connect = require('connect'),
        User = require('../models/user');

module.exports = router(function(app){
        app.get('/login.html', connect['static'](__dirname));
        app.post('/login.html', connect.bodyParser(), function(req, res) {
                // console.log('logging in');
                if (req.session.userId) { console.log('Logging in but, but already have userId'); }
                // console.log(req.body);
                User.findOne({login: req.body.login, password: req.body.password}, function(err, doc){
                        if (err || !doc) { 
                                res.end('Bad username or password');
                                // res(err || 'Bad username or password'); 
                        } else {
                                doc.dologin(req.session, req.sessionID, function(err) {
                                        if (err) {console.error(err);}
                                        res.writeHead(302, {Location: '/selectpc'});
                                        res.end();
                                });
                        }
                });
        });
});
