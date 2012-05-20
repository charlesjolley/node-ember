
require('./core');
require('./user_view');

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

exports.contact = contact;
exports.userView = userView;
