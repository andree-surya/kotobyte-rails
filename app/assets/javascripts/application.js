// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

var dismissPopups = function(event) {

  var targetNode = $(event.target);
  var popups = Popup.getInstances();

  for (var i = 0; i < popups.length; i++) {
    var popup = popups[i];

    if (popup.isVisible() 
        && ! popup.contains(targetNode) 
        && ! popup.anchoredAt(targetNode)) {

      popup.hide();
    }
  }
};

$(function() {
  $('#search_form input[name=query]').focus().select();

  if ('ontouchstart' in document.body) {
    document.body.ontouchstart = dismissPopups;

  } else {
    document.body.onclick = dismissPopups;
  }
});
