do ->

  NODE_TEMPLATE = _.template """
    <h4><%- node %></h4>
    <ul class="im-possible-attributes"></ul>
  """

  class PossibleColumn extends intermine.views.ItemView

    tagName: 'li'

    className: 'im-possible-column'

    initialize: ->
      @on 'rendered', @showDisplayName, @
      @on 'rendered', @setClassName, @
      @model.on 'destroy', @remove, @

    events:
      'click': 'addToExportedList'

    addToExportedList: ->
      console.log 'clicked'
      @model.trigger 'selected' unless @model.get 'alreadySelected'

    setClassName: ->
      @$el.toggleClass 'im-already-selected', @model.get('alreadySelected')

    showDisplayName: ->
      path = @model.get 'path'
      # Demeter violations coming up!! TODO.
      canonical = path.model.getPathInfo "#{ path.getParent().getType().name }.#{ path.end.name }"
      canonical.getDisplayName().done (name) =>
        @$('.im-field-name').text name.split(' > ').pop()
        @model.trigger 'displayed-name'

    template: _.template """
      <a href="#">
        <i class="<% if (alreadySelected) { %>#{ intermine.icons.Check }<% } else { %>#{ intermine.icons.UnCheck }<% } %>"></i>
        <span class="im-field-name"><%- path %></span>
      </a>
    """

  class PopOver extends Backbone.View

    tagName: 'ul'
    className: 'im-possible-attributes'

    initialize: ->
      @collection = new Backbone.Collection
      @collection.on 'selected', @selectPathForExport, @
      @collection.on 'displayed-name', @sortUL, @
      @initFields()

    initFields: ->
      @collection.reset()
      for path in @options.node.getChildNodes() when @isSuitable path
        alreadySelected = @options.exported.any (x) -> path.equals x.get 'path'
        @collection.add {path, alreadySelected}

    isSuitable: (p) ->
      ok = p.isAttribute() and (intermine.options.ShowId or (p.end.name isnt 'id'))

    remove: ->
      @collection.each (m) ->
        m.destroy()
        m.off()
      @collection.off()
      super(arguments...)

    sortUL: ->
      lis = @$('li').get()
      sorted = _.sortBy lis, (li) -> $(li).find('.im-field-name').text()
      @$el.empty().append sorted
      @trigger 'needs-repositioning'

    selectPathForExport: (model) ->
      @collection.remove model
      @options.exported.add path: model.get 'path'
      model.destroy()
      model.off()

    render: ->
      @collection.each (model) =>
        item = new PossibleColumn {model}
        item.render()
        @$el.append item.el
      this

  class QueryNode extends Backbone.View

    tagName: 'div'

    className: 'im-query-node btn'

    initialize: ->
      @model.collection.on 'popover-toggled', (other) =>
        @$el.popover 'hide' unless @model is other
      @model.on 'destroy', @remove, @
      exported = @model.collection.exported
      exported.on 'add remove', @render, @
      node = @model.get 'node'
      @content = new PopOver({node, exported}).render()
      @content.on 'needs-repositioning', => @$el.popover 'show'

    remove: ->
      console.log "Cleaning up #{ @model.get 'node' }"
      @$el.popover 'hide'
      @content.remove()
      delete @content
      super(arguments...)

    events:
      'click': 'togglePopover'

    togglePopover: ->
      @$el.popover 'toggle'
      @model.trigger 'popover-toggled', @model

    render: ->

      data = @model.toJSON()
      @$el.empty()
      @$el.html NODE_TEMPLATE data
      ul = @$ 'ul'

      data.node.getDisplayName().done (name) =>
        [parents..., end] = name.split(' > ')
        @$('h4').text end

      @$el.popover
        container: @$el.closest('.bootstrap')
        html: true
        trigger: 'manual'
        placement: 'top'
        content: @content.el
        title: (tip) => @$('h4').text()
      
      this

  class PossibleColumns extends Backbone.View

    tagName: 'div'

    className: 'im-possible-columns btn-group'

    render: ->

      @collection.each (model) =>
        item = new QueryNode {model}
        el = item.render().$el
        @$el.append el

      this

  scope 'intermine.columns.views', {PossibleColumns}