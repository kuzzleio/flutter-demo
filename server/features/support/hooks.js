'use strict';

const
  _ = require('lodash'),
  { After, Before, AfterAll, BeforeAll } = require('cucumber'),
  { Kuzzle, WebSocket } = require('kuzzle-sdk'),
  defaultMappings = require('../../fixtures/default-mappings'),
  testMappings = require('../fixtures/mappings'),
  testFixtures = require('../fixtures/fixtures'),
  testSecurities = require('../fixtures/securities'),
  World = require('./world');

BeforeAll(async function () {
  const
    world = new World({ });

  world.kuzzle = new Kuzzle(
    new WebSocket(world.host, { port: world.port })
  );  
  
  await world.kuzzle.connect();

  console.log('Loading default securities..');

  await world.kuzzle.query({
    controller: 'admin',
    action: 'loadSecurities',
    body: testSecurities,
    refresh: 'wait_for'
  });

  world.kuzzle.disconnect();
});

Before(async function () {
  const
    mappings = Object.assign({}, testMappings, defaultMappings);

  this.kuzzle = new Kuzzle(
    new WebSocket(this.host, { port: this.port })
  );  
  
  await this.kuzzle.connect();

  await this.kuzzle.query({
    controller: 'admin',
    action: 'loadMappings',
    body: mappings,
    refresh: 'wait_for'
  });

  await this.kuzzle.query({
    controller: 'admin',
    action: 'loadFixtures',
    body: testFixtures,
    refresh: 'wait_for'
  });  
});

After(function () {
  // Clean values stored by the scenario
  this.props = {};

  if (this.kuzzle && typeof this.kuzzle.disconnect === 'function') {
    return this.kuzzle.query({
      controller: 'admin',
      action: 'resetDatabase',
      refresh: 'wait_for'
    })
      .then(() => {
        this.kuzzle.disconnect();
      });
  }
});
