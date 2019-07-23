const
  should = require('should'),
  {
    Given,
    Then
  } = require('cucumber');

Given('a collection {string}:{string}', async function (index, collection) {
  await this.kuzzle.index.create(index);
  await this.kuzzle.collection.create(index, collection);

  this.props.index = index;
  this.props.collection = collection;
});

Given('I create the document {string} with id {string}', async function (documentRaw, documentId) {
  const document = JSON.parse(documentRaw);

  await this.kuzzle.document.create(this.props.index, this.props.collection, document, documentId);
});

Then('The document {string} has a property {string}', async function (documentId, propertyName) {
  const response = await this.kuzzle.document.get(this.props.index, this.props.collection, documentId);

  should(response._source[propertyName]).not.be.undefined();
});
