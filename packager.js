
require('./ember-handlebars');
var FS = require('fs');

// Precompiles Handlebars templates when used with a convoy pipeline
function HandlebarsCompiler(asset, context, done) {
  FS.readFile(asset.path, 'utf8', function(err, data) {
    if (err) return done(err);
    asset.body = "module.exports = " + Ember.Handlebars.precompile(data) + ";";
    done();
  });
}

exports.HandlebarsCompiler = HandlebarsCompiler;
