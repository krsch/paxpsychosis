var ss = require('socketstream'),
        ko = require('knockout');

var pcs = ko.observableArray(),
        userdata = ko.observable({name: '', admin: false}),
        newname = ko.observable();

ss.server.on('ready', function(){
        ss.rpc('user.listpc', function(err, pclist) {
                if (err) { console.error(err); }
                pcs(pclist);
        });

        ss.rpc('user.info', function(err, doc) {
                if (err) { console.error(err); }
                console.log(doc);
                userdata(doc);
        });
});
// console.log('js works');
$(function(){
        ko.applyBindings({
                pcs: pcs,
                newname: newname,
                userdata: userdata,
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
