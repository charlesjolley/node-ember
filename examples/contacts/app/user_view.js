
require('./core');

Contacts.UserView = Ember.View.extend({
  contact: null,
  template: require('./user_template'),
  classNames: ['user']
});

