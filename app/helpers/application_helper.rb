module ApplicationHelper
  TOUCH_ICON_SIZES = [60, 76, 120, 152, 180].freeze
  TOUCH_ICON_RELS = ['apple-touch-icon', 'icon'].freeze

  def favicon_tags
    tags = []

    tags << favicon_link_tag('favicon.ico')

    TOUCH_ICON_SIZES.each do |size|
      TOUCH_ICON_RELS.each do |rel|
        options = { rel: rel, sizes: "#{size}x#{size}", type: 'image/png' }

        tags << favicon_link_tag("touch-#{size}.png", options)
      end
    end

    raw tags.join("\n")
  end

  def menu_popup_tag
    content_name = (if signed_in? then 'menu' else 'sign-in' end)

    content_tag 'div', id: "popup-menu", class: 'popup' do
      render partial: (if signed_in? then 'menu' else 'sign_in' end)
    end
  end
end
