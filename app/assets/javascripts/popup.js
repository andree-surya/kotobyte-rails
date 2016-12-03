
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

Popup.currentlyShownPopup = null;

Popup.activate = function() {

  var hoverableAnchors = $('[data-popup-trigger="hover"]');
  var clickableAnchors = $('[data-popup-trigger="click"]');

  var handleDismiss = function(event) {

    var nonDismissableRegion = 
        $(event.target).closest('.popup, [data-popup-trigger="hover"]');

    if (nonDismissableRegion.length == 0 && Popup.currentlyShownPopup != null) {
      Popup.currentlyShownPopup.hide();
    }
  };

  var handleClick = function(event) {
    
    var clickedPopup = new Popup(this);

    if (Popup.currentlyShownPopup == null ||
        ! clickedPopup.hasEqualAnchor(Popup.currentlyShownPopup)) {

      if (Popup.currentlyShownPopup != null) {
        Popup.currentlyShownPopup.hide();
      }
     
      clickedPopup.show();
      return false;
    }
  };

  var handleHover = function(event) {
    
    var popup = new Popup(this);

    if (event.type == 'mouseenter') {
      popup.show();

    } else {
      popup.hide();
    }
  };

  if ('ontouchstart' in document.body) { // Touch device?
    document.body.ontouchstart = handleDismiss;

    clickableAnchors.click(handleClick);
    hoverableAnchors.click(handleClick);

  } else {
    document.body.onclick = handleDismiss;

    clickableAnchors.click(handleClick);
    hoverableAnchors.hover(handleHover);
  }
};

Popup.prototype.show = function() {

  if (this.anchorNode.data('popup-text')) {
    this.text(this.anchorNode.data('popup-text'));

  } else if (this.anchorNode.data('popup-src')) {
    this.load(this.anchorNode.data('popup-src'));
  }
  
  this.popupNode.show();
  this.updatePosition();

  Popup.currentlyShownPopup = this;
};

Popup.prototype.hide = function() {
  this.popupNode.hide();

  if (this == Popup.currentlyShownPopup) {
    Popup.currentlyShownPopup = null;
  }
};

Popup.prototype.isVisible = function() {
  return this.popupNode.is(':visible');
};

Popup.prototype.hasEqualAnchor = function(anotherPopup) {
  return this.anchorNode.is(anotherPopup.anchorNode);
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

