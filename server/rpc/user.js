var Pc = require('../models/pc'),
        User = require('../models/user');

exports.actions = function(req,res,ss){
        req.use('session');
        req.use('auth.authenticated');
        return {
          addpc: function(name){
                loc = [ 37.58341312408447, 55.70879918673729 ];
                skills = {first: [ {name: 'nothing', level: 0} ]};
                console.log('creating pc ' + name);
                Pc.create({name: name, loc: loc, userId: req.session.userId, skills: skills}, function(err,doc){
                        if (err) {console.error(err); }
                        res(err, doc);
                        console.log("created pc " + name);
                        ss.publish.user(req.session.userId, 'pc:add', doc);
                });
          },
          listpc: function(){
                Pc.json_by_user(req.session.userId, res);
          },
          selectpc: function(pc_id){
                  User.findById(req.session.userId, function(err, user) {
                          if (err) { res(err); }
                          else { user.selectpc(pc_id, req.session, res); }
                  });
          },
          name: function(){
                  User.findById(req.session.userId, function(err, doc) {
                          if (!err) { res(null, doc.login); }
                          else { res(err); }
                  });
          }
        };
};
