require('../fixes')
ss = require('socketstream').start()
global.cache = pc: {}
global.wrapRPC = (done)-> (args)->done(args...)
