var Pc = require('../models/pc'),
        User = require('../models/user');

exports.actions = function(req,res,ss){
        req.use('session');
        req.use('auth.authenticated');
        return {
          addpc: function(name){
                loc = [ 37.58341312408447, 55.70879918673729 ];
                skills = {first: {nothing: 0}};
                var pc = new Pc.create({name: name, loc: loc, userId: req.userId, skills: skills});
                console.log('creating pc ' + name);
                pc.save(function(err,doc){
                        if (err) {console.error(err); }
                        res(err, doc);
                        ss.publish.user('pc:add', doc);
                        console.log("created pc " + name);
                });
          },
          listpc: function(){
                Pc.by_user(req.session.userId, res);
          },
          name: function(){
                  User.findById(req.session.userId, function(err, doc) {
                          if (err) { res(null, doc.name); }
                          else { res(err); }
                  });
          }
        };
};
