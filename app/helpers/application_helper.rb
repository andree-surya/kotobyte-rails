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
end
