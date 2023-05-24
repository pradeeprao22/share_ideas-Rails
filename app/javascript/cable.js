// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `rails generate channel` command.
//
//= require action_cable
//= require_self
//= require channels/messages
//= require channels/notifications
//= require channels/posts

(function() {
  this.LondevApp || (this.LondevApp = {});

  LondevApp.cable = ActionCable.createConsumer();

}).call(this);
