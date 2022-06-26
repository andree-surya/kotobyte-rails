
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

Popup.attachListeners = function() {

  var hoverableAnchors = $('[data-popup-trigger="hover"]');
  var clickableAnchors = $('[data-popup-trigger="click"]');

  var handleDismiss = function(event) {

    var nonDismissableRegion = 
        $(event.target).closest('.popup, [data-popup-trigger="hover"]');

    if (nonDismissableRegion.length == 0) {
      Popup.hideAll();
    }
  };

  var handleClick = function(_event) {
    
    var popup = new Popup(this);
   
    if (! popup.isVisible()) {

      Popup.hideAll();
      popup.show();

      return false;

    } else {
      popup.hide();
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

Popup.hideAll = function() {
  $('.popup:visible').hide();
};

/**
 * Show this popup node, populate popup body, and update position
 */
Popup.prototype.show = function() {

  if (this.anchorNode.data('popup-text')) {
    this.text(this.anchorNode.data('popup-text'));

  } else if (this.anchorNode.data('popup-src')) {
    this.load(this.anchorNode.data('popup-src'));
  }
  
  this.popupNode.show();
  this.updatePosition();
};

/**
 * Hide this popup node
 */
Popup.prototype.hide = function() {
  this.popupNode.hide();
};

/**
 * Whether this popup node is visible
 * @return {Boolean}
 */
Popup.prototype.isVisible = function() {
  return this.popupNode.is(':visible');
};

Popup.prototype.hasEqualAnchor = function(anotherPopup) {
  return this.anchorNode.is(anotherPopup.anchorNode);
};

/**
 * Load an HTML page into popup body and display
 * @param {String} src HTML source
 */
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

/**
 * Set an HTML text into popup body and display
 * @param {String} text HTML text
 */
Popup.prototype.text = function(text) {
  this.popupNode.html(text);
};

/**
 * Update popup position relative to its anchor
 */
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

