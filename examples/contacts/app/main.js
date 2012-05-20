
require('html5-manifest'); // required to kickstart the autorefresh
require('./core');
require('./user_view');
$ = require('jquery');

contact = Ember.Object.create({
  firstName: 'Charles',
  lastName:  'Jolley',
  fullName: function() {
    return [this.get('firstName'), this.get('lastName')].join(' ');
  }.property('firstName', 'lastName')
});

userView = Contacts.UserView.create();
userView.append();
userView.set('contact', contact);

// cleanup loading UI
$('h1.loading').remove();

exports.contact = contact;
exports.userView = userView;

END = new Date().getTime();
console.log('Load time: ' + (END-START) + 'msec');
