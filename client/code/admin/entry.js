var ss = require('socketstream');
var ko = require('knockout');

var     comment = ko.observable(''),
        invites = ko.observableArray();

var app = Davis(function(){
        this.settings.generateRequestOnPageLoad = true;
        this.settings.formSelector = 'form.davis';
        this.get('/admin/', function(req){
                $('#content').html('<h1>Admin panel</h1>');
        });
        this.get('/admin/invites', function(req){
                $('#content').html(ss.tmpl.invites.r());
                ko.applyBindings({
                        invites: invites,
                        create: function(){
                                ss.rpc('admin.invite.create', comment(), function(err){
                                        if (err) { console.error(err); }
                                        else {comment('');}
                                });
                        },
                        used: function(doc){
                                return doc && doc.user!==undefined;
                        },
                        prefix: '/registration/',
                        comment: comment
                });
        });
});

ss.server.on('ready', function() {
        ss.rpc('admin.invite.list', function(err, docs) {
                if (err) { console.error(err); }
                invites(docs);
        });
});

ss.event.on('invite:add', function(invite) {
        invites.push(invite);
});
