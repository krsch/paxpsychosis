# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
_ = require('lodash')
Q = require('q')

exports.actions = (req,res,ss) ->
    save: (questions, answers)->
        Answer = require('../models/answer')
        Question = require('../models/question')
        is_temp = (x)->/^---/.test(x)
        ids_map = {}
        promise = Q.all questions.map (question)->
            oid = question._id
            delete question._id
            defer = Q.defer()
            if is_temp(oid)
                Question.create(question, defer.makeNodeResolver())
                defer.promise.then (doc)->ids_map[oid] = doc._id
            else
                Question.findByIdAndUpdate(oid, question, defer.makeNodeResolver())
            defer.promise
        promise.then ->
            console.log(answers)
            promise_ans = Q.all answers.map (ans)->
                ans.from = ids_map[ans.from] if is_temp(ans.from)
                ans.to = ids_map[ans.to] if is_temp(ans.to)
                defer = Q.defer()
                id = ans._id
                delete ans._id
                if is_temp(id)
                    Answer.create(ans,defer.makeNodeResolver())
                    defer.promise.then (doc)->ids_map[id] = doc._id
                else
                    Answer.findByIdAndUpdate(id, ans, defer.makeNodeResolver())
                defer.promise
        .then ->
            res(null, ids_map)
        .fail (err)->
            res(err)
            console.error(err)
    load: (id)->
        Answer = require('../models/answer')
        Question = require('../models/question')
        Question.find {dialog: id}, (err,questions)->
            if err
                console.error(err)
            else
                Answer.find {dialog: id}, (err, answers)->
                    console.error(err) if err
                    res(err,questions, answers)
