// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
function Look(id, look){
        this.id = id;
        this.look = look;
}
exports.actions = function(req, res, ss) {
        req.use('pc.load', req);
        return {
                start: function(id) {
                        req.session.look = req.session.look || {};
                        var session = req.session.look;
                        if (session[id]) {
                                req.pc.publish('look', new Look(id, session[id]) );
                        } else {
                                setTimeout(function() {
                                        session[id] = 'You know much';
                                        req.session.save(function(err){
                                                if (err) { console.error(err); }
                                                req.pc.publish('look', new Look(id, session[id]) );
                                        });
                                }, 3000);
                        }
                }
        };
};
