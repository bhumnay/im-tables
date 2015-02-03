Collection = require '../core/collection'
HeaderModel = require './header'

buildHeaders = require '../utils/build-headers'

module.exports = class ColumnHeaders extends Collection

  model: HeaderModel

  comparator: 'index'

  initialize: ->
    super
    @listenTo @, 'change:index', @sort

  setHeaders: (query, banList) -> buildHeaders(query, banList).then (newHeaders) =>
    @set(new HeaderModel h, query for h in newHeaders)

