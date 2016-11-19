
var showKanjiPopup = function(event) {

  var link = $(event.target);
  var popup = Popup.getInstance('kanji_popup');

  if (popup.anchoredAt(link)) {
    popup.hide();

  } else {
    var linkURL = link.attr('href');

    popup.load(linkURL);
    popup.showAt(link);
  }

  event.preventDefault();
  event.stopPropagation();
};

var showCategoryPopup = function(event) {

  var popup = Popup.getInstance('category_popup');

  var link = $(event.target);
  var text = link.data('text');

  popup.content(text);
  popup.showAt(link);
};

var dismissCategoryPopup = function(event) {

  Popup.getInstance('category_popup').hide();
}
