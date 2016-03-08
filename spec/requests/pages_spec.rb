require 'rails_helper'

RSpec.describe "Page: ", type: :request do
  let!(:page1) { FactoryGirl.create(:page) }
  let!(:page2) { FactoryGirl.create(:page, parent_page_id: page1.id) }
  let!(:page3) { FactoryGirl.create(:page, parent_page_id: page2.id) }
  
  describe "home" do
    before do 
      get root_path
    end
    it "should have pages tree" do
      expect(response.body).to match("<ul><li>#{page1.name}<ul>"<<
        "<li>#{page2.name}<ul><li>#{page3.name}</li></ul></li></ul></li></ul>")
    end
  end
end
