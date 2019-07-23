const
  {
    Given
  } = require('cucumber');

Given('I log into Kuzzle as user {string} with password {string}', function (username, password) {
  return this.kuzzle.auth.login('local', { username, password });
});
