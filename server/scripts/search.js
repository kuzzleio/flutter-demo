const { Kuzzle, WebSocket } = require('kuzzle-sdk');

const kuzzle = new Kuzzle(new WebSocket('localhost', { port: 7512 }));

kuzzle.on('networkError', error => {
  console.error(`Network Error: ${error.message}`);
});

(async () => {
  try {
    await kuzzle.connect();
    const results = await kuzzle.document.search(
      'world',
      'collectable',
      {
        query: {
          bool: {
            must: {
              match_all : {}
            },
            filter: {
              geo_distance: {
                distance: '10m',
                'location': {
                  lat: 43.6013872,
                  lon: 3.9005778
                }
              }
            }
          }
        }
      }
    );
    console.log(results.);
  } catch (error) {
    console.log(error);
  } finally {
    kuzzle.disconnect();
  }
})();