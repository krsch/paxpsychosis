var ss = require('socketstream'),
        ko = require('knockout');

var pcs = ko.observableArray(),
        username = ko.observable(),
        newname = ko.observable();

// console.log('js works');
$(function(){
        ss.rpc('user.listpc', function(err, pclist) {
                if (err) { console.error(err); }
                pcs(pclist);
        });

        ss.rpc('user.name', function(err, name) {
                if (err) { console.error(err); }
                console.log(name);
                username(name);
        });

        ko.applyBindings({
                pcs: pcs,
                newname: newname,
                username: username,
                selectpc: function() {
                        ss.rpc('user.selectpc', this._id, function(err) {
                                if (err) {console.error(err); }
                                else { window.location = '/'; }
                        });
                },
                create: function(){ss.rpc('user.addpc', newname());}
        });
});

ss.event.on('pc:add', function(pc){
        pcs.push(pc);
});
