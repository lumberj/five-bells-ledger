/* @flow */
'use strict';

var transfers = require('./controllers/transfers');
var holds = require('./controllers/holds');
var people = require('./controllers/people');
var subscriptions = require('./controllers/subscriptions');
var compress = require('koa-compress');
var serve = require('koa-static');
var route = require('koa-route');
var cors = require('koa-cors');
var errorHandler = require('./middlewares/error-handler');
var koa = require('koa');
var path = require('path');
var log = require('./services/log');
var logger = require('koa-mag');
var config = require('./services/config');
var app = module.exports = koa();

// Logger
app.use(logger());
app.use(errorHandler);
app.use(cors({ expose: ['link'] }));

app.use(route.get('/transfers/:id', transfers.fetch));
app.use(route.put('/transfers/:uuid', transfers.create));

app.use(route.get('/holds/:id', holds.fetch));
app.use(route.put('/holds/:uuid', holds.create));

app.use(route.get('/people/:id', people.fetch));

app.use(route.get('/subscriptions/:id', subscriptions.fetch));
app.use(route.post('/subscriptions', subscriptions.create));
app.use(route.delete('/subscriptions/:id', subscriptions.remove));

// Serve static files
app.use(serve(path.join(__dirname, 'public')));
app.use(serve(path.join(__dirname, 'public')));

// Compress
app.use(compress());

if (!module.parent) {
  app.listen(config.server.port);
  log('app').info('listening on port '+config.server.port);
}
