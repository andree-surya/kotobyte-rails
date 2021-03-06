require 'rails_helper'

describe ApplicationHelper, type: :helper do

  describe '#favicon_tags' do
    let(:tags) { favicon_tags }

    it 'should include a favicon.ico image' do
      expect(tags).to include ('favicon.ico')
    end

    it 'should include correct number of apple touch icons' do
      matches = tags.scan /rel="apple-touch-icon"/

      expect(matches.count).to eq(ApplicationHelper::TOUCH_ICON_SIZES.count)
    end

    it 'should include correct number of Android home icons' do
      matches = tags.scan /rel="icon"/

      expect(matches.count).to eq(ApplicationHelper::TOUCH_ICON_SIZES.count)
    end
  end
end 
