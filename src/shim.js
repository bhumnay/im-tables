// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Ugly, since we leak jQuery, but only for the duration of this call
let $;
const oldjq = global.jQuery;

const jQuery = ($ = require('jquery'));

// Install jQuery on Backbone
const Backbone = require('backbone');
Backbone.$ = jQuery;

global.jQuery = $; // Yes, bootstrap *requires* jQuery to be global
// jQuery should now be available to bootstrap to attach.
require('bootstrap'); // Extend our jQuery with bootstrappy-goodness.
require('typeahead.js'); // Load the typeahead library.
// Load jquery-ui components.
require('jquery-ui-bundle');
// Restore previous state.
if (oldjq != null) {
  global.jQuery = oldjq;
} else {
  delete global.jQuery;
}
