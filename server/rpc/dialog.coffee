# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

exports.actions = (req,res,ss) ->
    save: (json)->
        Question = require('../models/question')
        json.forEach (question)->
            if '_id' of question
                id = question._id
                delete question._id
                delete question.newid
                Question.update {_id: id}, question, (err, res)->
                    console.log(err) if err
                    console.log(res)
            else
                Question.create question, (err, res)->
                    console.log(err) if err
                    console.log(res)

        res(null, true)
    load: (id)->
        Dialog = require('../models/dialog')
        Question = require('../models/question')
        Question.find {dialog: id}, (err,questions)->
            console.error(err) if err
            res(err,questions)
