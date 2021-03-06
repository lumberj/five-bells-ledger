const UriManager = require('five-bells-shared/lib/uri-manager').UriManager
const config = require('./config')

const uri = module.exports = new UriManager(config.server.base_uri)

uri.addResource('account', '/accounts/:id')
uri.addResource('transfer', '/transfers/:id')
uri.addResource('subscription', '/subscriptions/:id')
