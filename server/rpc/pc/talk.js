// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
exports.actions = function(req, res, ss) {
        req.use('pc.load', req);
        return {
                start: function(id) {
                        if (req.session.talk[id]) {
                                res(null, req.session.talk[id]);
                        } else {
                                req.session.talk[id] = {
                                        dialog: null
                                };
                        }
                }
        };
};
