
var Popup = function(popupNode) {
  this.popupNode = popupNode;
  this.pointerNode = popupNode.find('.pointer');
  this.contentNode = popupNode.find('.content');
};

Popup.sharedInstances = new Object;

Popup.getInstance = function(id) {
  var popup = this.sharedInstances[id];

  if (popup == null) {
    var popupNode = $('<div>', { id: id, class: 'popup' });
    var pointerNode = $('<div>', { class: 'pointer' });
    var contentNode = $('<div>', { class: 'content' });

    popupNode.append(pointerNode);
    popupNode.append(contentNode);
    $('main').append(popupNode);

    popup = new Popup(popupNode);
    this.sharedInstances[id] = popup;
  }

  return popup;
};

Popup.getInstances = function() {
  var popups = [];

  for (var id in this.sharedInstances) {
    popups.push(this.sharedInstances[id]);
  }

  return popups;
};

Popup.prototype.showAt = function(anchorNode) {
  this.anchorNode = anchorNode;

  this.popupNode.show();
  this.updatePosition();
};

Popup.prototype.hide = function() {
  this.anchorNode = null;
  this.popupNode.hide();
};

Popup.prototype.isVisible = function() {
  return this.popupNode.is(':visible');
};

Popup.prototype.contains = function(node) {
  return this.popupNode.is(node) || this.popupNode.has(node).length > 0;
};

Popup.prototype.anchoredAt = function(anchorNode) {
  return this.anchorNode && this.anchorNode.is(anchorNode);
};

Popup.prototype.load = function(url) {

  var contentNode = this.contentNode;
  contentNode.html('Loading ...');

  $.ajax({
    url: url,
    async: true,
    cache: true,

    success: function(result) {
      contentNode.html(result);
    }
  });
};

Popup.prototype.content = function(content) {
  this.contentNode.html(content);
};

Popup.prototype.updatePosition = function() {

  var pointerSize = 8;
  var documentWidth = $(document).width();
  var documentHeight = $(document).height();
  var anchorOffset = this.anchorNode.offset();

  var pointerCenterX = anchorOffset.left + this.anchorNode.width() / 2;
  var pointerOffsetX = pointerCenterX - pointerSize;

  var offsetY = anchorOffset.top + this.anchorNode.height() + pointerSize;
  var offsetX = pointerCenterX - this.popupNode.width() / 2;

  if (offsetX < 0) {
    offsetX = 0;

  } else if (offsetX + this.popupNode.width() > documentWidth) {
    offsetX = documentWidth - this.popupNode.width();
  }

  this.popupNode.offset({ top: offsetY, left: offsetX });
  this.pointerNode.offset({ left: pointerOffsetX });
};
