_ = require 'underscore'

Model = require '../core-model'

mergeOldAndNew = (oldValue, newValue) ->
  _.extend {}, (if _.isObject oldValue then oldValue else {}), newValue

setSection = (m, k) ->
  v = m[k]
  if not _.isObject(v) # mid-sections must be indexable objects (including arrays)
    m[k] = {}
  else
    v

# A version of Model that supports nested keys.
module.exports = class NestedModel extends Model

  _triggerChangeRecursively: (ns, obj) ->
    for k, v of obj
      thisKey = "#{ ns }.#{ k }"
      if _.isObject v
        @_triggerChangeRecursively thisKey, v
      else
        @trigger "change:#{ thisKey }", @, @get(thisKey)

  get: (key) -> # Support nested keys
    if _.isArray(key)
      [head, tail...] = key
      # Safely get properties.
      tail.reduce ((m, k) -> m and m[k]), super head
    else if /\w+\.\w+/.test key
      @get key.split /\./
    else
      super key

  _triggerPathChange: (key) ->
    path = []
    for section in key
      path.push section
      @trigger "change:#{ path.join('.') }", this, @get path

  _triggerUnsetPath: (path, prev) ->
    if _.isObject(prev)
      for k, v of prev
        @_triggerUnsetPath path.concat([k]), v
    else
      @trigger "change:#{ path.join('.') }"

  # See tests for specification.
  set: (key, value) -> # Support nested keys
    throw new Error("No key") unless key?
    if _.isArray(key) # Handle key paths.
      # Recurse into subkeys.
      if _.isObject(value) and not _.isArray(value)
        for k, v of value
          @set key.concat([k]), v
        return

      [head, mid..., end] = key
      headVal = @get head
      # Ensure the root is an object.
      if headVal and (not _.isObject headVal) # primitive - unset it first.
        @unset head
      # Merge or create new path to value
      root = (headVal ? {})
      currentValue = mid.reduce setSection, root
      prev = currentValue[end]
      currentValue[end] = value
      super head, root
      @_triggerPathChange key
      if prev? and not value?
        @_triggerUnsetPath key, prev
    else if _.isString(key) # Handle calls as (String, Object) ->
      if /\w+\.\w+/.test key
        @set (key.split /\./), value
      else if _.isObject(value) and not _.isArray(value)
        @set [key], value
      else
        super # Handle simple key-value pairs, including unset.
    else # Handle calls as (Object) ->, but ignore the options object.
      for k, v of key
        @set k, v

