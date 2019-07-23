const
  should = require('should'),
  {
    When,
    Then
  } = require('cucumber');

When(/I call the( plugin)? route "(.*)":"(.*)"/, async function (plugin, controller, action) {
  if (plugin) {
    controller = `${this.pluginName}/${controller}`;
  }

  const response = await this.kuzzle.query({
    controller,
    action
  });

  this.props.result = response.result;
});

Then('I should receive a text result containing {string}', function (expectatedResult) {
  should(this.props.result).be.type('string');
  should(this.props.result).be.eql(expectatedResult);
});
