
require('./core');

Contacts.UserView = Ember.View.extend({
  contact: null, // user goes here
  template: require('./user_template'),
  classNames: ['user'],
  firstName: 'JOHN'
});

