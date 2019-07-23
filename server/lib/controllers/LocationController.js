/*
 * Kuzzle, a backend software, self-hostable and ready to use
 * to power modern apps
 *
 * Copyright 2015-2018 Kuzzle
 * mailto: support AT kuzzle.io
 * website: http://kuzzle.io
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
const mapKeys = require('lodash.mapkeys');
const randomLocation = require('random-location');
const BaseController = require('./BaseController');

/**
 * @class LocalisationController
 * @extends BaseController
 */
class LocalisationController extends BaseController {

  constructor (context, config) {
    super(context, config);

    this.name = 'location';

    this.actions = [
      'register'
    ];

    this.routes = [
      { verb: 'post', url: '/register', action: 'register'}
    ];
  }

  /**
   * Check if there are entities around the player who register his position.
   * If not, instantiate entities around him.
   * @param {Request} request 
   */
  async register (request) {
    const lat = this.floatParam(request, 'latitude');
    const lon = this.floatParam(request, 'longitude');

    const results = await this.sdk.document.search(
      'world',
      'collectable',
      {
        query: {
          bool: {
            must: { match_all: {} },
            filter: {
              geo_distance: {
                distance: '100m',
                location: { lat, lon }
              }
            }
          }
        }
      }
    );

    if (results.total) {
      return true;
    }

    const { hits: entities } = await this.sdk.document.search(
      'world',
      'entities',
      { query: {} }
    );

    const P = {
      latitude: lat,
      longitude: lon
    };
    
    const newCollectable = Array(20)
      .fill(null)
      .map(() => ({
        body: {
          entity: entities[Math.floor(Math.random() * entities.length)]._id,
          location: mapKeys(randomLocation.randomCirclePoint(P, 100), (_, k) => k.substr(0, 3))
        }
      }));

    await this.sdk.document.mCreate(
      'world',
      'collectable',
      newCollectable
    );

    return true;
  }
}

module.exports = LocalisationController;