
require('./handlebars');
var FS = require('fs');

// Precompiles Handlebars templates when used with a convoy pipeline
function HandlebarsCompiler(asset, context, done) {
  FS.readFile(asset.path, 'utf8', function(err, data) {
    if (err) return done(err);
    asset.body = [
      "var templateSpec = "+ Ember.Handlebars.precompile(data).toString() +";",
      "module.exports = Ember.Handlebars.VM.template(templateSpec);"
    ].join("\n");
    done();
  });
}

exports.HandlebarsCompiler = HandlebarsCompiler;
