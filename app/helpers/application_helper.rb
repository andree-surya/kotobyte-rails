module ApplicationHelper
  TOUCH_ICON_SIZES = [60, 76, 120, 152, 180]
  TOUCH_ICON_RELS = ['apple-touch-icon', 'icon']

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

  def google_meta_tags

    tag(:meta, {
        name: 'google-signin-client_id', 
        content: Rails.configuration.app[:google_client_id]
    })
  end
end
