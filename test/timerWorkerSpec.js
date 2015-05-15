/*global describe, it*/
'use strict';
const chai = require('chai');
const expect = chai.expect;
const sinon = require('sinon');
const sinonChai = require('sinon-chai');
chai.use(sinonChai);
const logHelper = require('@ripple/five-bells-shared/testHelpers/log');
const TimerWorker = require('../lib/timerWorker').TimerWorker;
const TransferExpiryMonitor =
  require('../lib/transferExpiryMonitor').TransferExpiryMonitor;
const TimeQueue = require('../lib/timeQueue').TimeQueue;

const START_DATE = 1434412800000; // June 16, 2015 00:00:00 GMT

describe('TimerWorker', function() {
  logHelper();

  beforeEach(function() {
    this.clock = sinon.useFakeTimers(START_DATE, 'Date', 'setTimeout', 'clearTimeout');

    this.timeQueue = new TimeQueue();
    this.transferExpiryMonitor = new TransferExpiryMonitor(this.timeQueue);
    sinon.stub(this.transferExpiryMonitor,
               'processExpiredTransfers',
               function*() {
                return;
               });
    this.timerWorker = new TimerWorker(this.timeQueue, this.transferExpiryMonitor);
  });

  afterEach(function() {
    this.timerWorker.stop();
  });

  describe('.start()', function() {
    it('should add a listener to the timeQueue to watch for ' +
       'newly inserted transfers', function *() {

      yield this.timerWorker.start();
      expect(this.timeQueue.listeners('insert')).to.have.length(1);
    });

    it('should trigger the transferExpiryMonitor to process ' +
       'expired transfers when called', function *() {

      yield this.timerWorker.start();

      expect(this.transferExpiryMonitor.processExpiredTransfers)
        .to.have.callCount(1);
    });

    it('should set a timeout to trigger itself again at the expiry ' +
       'date of the earliest item in the timeQueue', function *() {

      yield this.timeQueue.insert(START_DATE + 100, 'hello');

      yield this.timerWorker.start();

      this.clock.tick(100);

      expect(this.transferExpiryMonitor.processExpiredTransfers)
        .to.have.callCount(2);
    });

    it('should be trigger the transferExpiryMonitor to process expired transfers each ' +
      'time a new item is inserted into the timeQueue', function *() {

      yield this.timerWorker.start();

      yield this.timeQueue.insert(START_DATE + 100, 'hello');
      yield this.timeQueue.insert(START_DATE + 200, 'hello');

      // The function will be called on the next tick
      yield Promise.resolve();
      expect(this.transferExpiryMonitor.processExpiredTransfers)
        .to.have.callCount(3);
    });

    it('should only have one timeQueue listener at a time, ' +
       'even if it is triggered by a timeout', function *() {

      yield this.timeQueue.insert(START_DATE + 100, 'hello');

      yield this.timerWorker.start();

      this.clock.tick(100);

      expect(this.timeQueue.listeners('insert')).to.have.length(1);
    });

    it('should keep the timeQueue ordered from earliest date to latest', function *() {

      yield this.timeQueue.insert(START_DATE + 100, 'hello');
      yield this.timeQueue.insert(START_DATE + 200, 'hello again');

      yield this.timerWorker.start();

      this.clock.tick(100);

      // The function will be called on the next tick
      yield Promise.resolve();
      expect(this.transferExpiryMonitor.processExpiredTransfers)
        .to.have.callCount(2);
    });

    it('should work with a timeout that is greater than the maximum for setTimeout',
      function *() {

      const max32int = 2147483647;

      yield this.timeQueue.insert(START_DATE + max32int + 1, 'hello');

      yield this.timerWorker.start();
      expect(this.transferExpiryMonitor.processExpiredTransfers)
        .to.have.callCount(1);

      this.clock.tick(1);

      yield Promise.resolve();
      expect(this.transferExpiryMonitor.processExpiredTransfers)
        .to.have.callCount(1);

      this.clock.tick(max32int);

      yield Promise.resolve();
      expect(this.transferExpiryMonitor.processExpiredTransfers)
        .to.have.callCount(2);

    });
  });
});
