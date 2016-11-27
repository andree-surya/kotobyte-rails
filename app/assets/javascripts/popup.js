
var Popup = function(anchorElement) {
  
  var anchorNode = $(anchorElement);
  var popupId = anchorNode.data('popup-id');

  if (! popupId) {
    anchorNode.data('popup-id', 'popup-' + Math.floor(Math.random() * 100000));
  }

  var popupNode = $('#' + popupId);

  if (popupNode.length == 0) {
    popupNode = $('<div>', { id: popupId }).hide();
    popupNode.appendTo(anchorNode.offsetParent());
  }

  this.popupNode = popupNode.addClass('popup');
  this.anchorNode = anchorNode;
};

Popup.activate = function() {

  $('[data-popup-trigger="click"]').click(function() {
    
    var popup = new Popup(this);

    if (! popup.isVisible()) {
      Popup.hideAll();
      popup.show();

      return false;
    }
  });

  
  $('[data-popup-trigger="hover"]').hover(function(event) {
    new Popup(this).show();

  }, function() {
    new Popup(this).hide();
  });

  $(document).on('click', function(event) {

    var clickWithoutDismissRegion = 
        $(event.target).closest('.popup, [data-popup-trigger="hover"]');
    
    if (clickWithoutDismissRegion.length == 0) {
      Popup.hideAll();
    }
  });

};

Popup.hideAll = function() {
  $('.popup:visible').hide();
};

Popup.prototype.show = function() {

  if (this.anchorNode.data('popup-text')) {
    this.text(this.anchorNode.data('popup-text'));

  } else if (this.anchorNode.data('popup-src')) {
    this.load(this.anchorNode.data('popup-src'));
  }
  
  this.popupNode.show();
  this.updatePosition();
};

Popup.prototype.hide = function() {
  this.popupNode.hide();
};

Popup.prototype.isVisible = function() {
  return this.popupNode.is(':visible');
};

Popup.prototype.load = function(src) {
  var popupNode = this.popupNode;

  if (popupNode.data('src') != src) {
    
    popupNode.data('src', src);
    popupNode.html('Loading ...');

    $.ajax({
      url: src,
      async: true,
      cache: true,

      success: function(result) {
        popupNode.html(result);
      },

      error: function(xhr, textStatus, errorThrown) {
        popupNode.removeData('src');
        popupNode.html(errorThrown);
      }
    });
  }
};

Popup.prototype.text = function(text) {
  this.popupNode.html(text);
};

Popup.prototype.updatePosition = function() {

  var documentWidth = $(document).innerWidth();
	var popupWidth = this.popupNode.outerWidth();
	var anchorWidth = this.anchorNode.outerWidth();
  
	var popupOffset = {};
	var anchorOffset = this.anchorNode.offset();

  popupOffset.top = anchorOffset.top + this.anchorNode.height() + 4;
  popupOffset.left = anchorOffset.left + (anchorWidth - popupWidth) / 2;

  if (popupOffset.left < 0) {
    popupOffset.left = 0;

  } else if (popupOffset.left + popupWidth > documentWidth) {
    popupOffset.left = documentWidth - popupWidth;
  }

  this.popupNode.offset(popupOffset);
};

