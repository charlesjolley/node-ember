
require('./handlebars');
var FS = require('fs');

// Precompiles Handlebars templates when used with a convoy pipeline
function HandlebarsCompiler(asset, context, done) {
  FS.readFile(asset.path, 'utf8', function(err, data) {
    if (err) return done(err);
    asset.body = [
      "var templateSpec = " + Ember.Handlebars.precompile(data) + ";",
      "var Utils = Ember.Handlebars.Utils",
      "module.exports = function(context, options) { ",
      "  options = options || {};",
      "  return templateSpec.call(Utils, Ember.Handlebars, context,",
      "    options.helpers, options.partials, options.data);",
      "};"].join("\n");
    done();
  });
}

exports.HandlebarsCompiler = HandlebarsCompiler;
