require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  render_views
  let!(:page1) { FactoryGirl.create(:page) }
  let!(:page2) { FactoryGirl.create(:page, parent_page_id: page1.id) }
  let!(:page3) { FactoryGirl.create(:page, parent_page_id: page2.id) }

  describe "'show' page" do
    context "for valid path" do
      before { get :show, { page_path: page3.path } }

      it "should show page information" do
        expect(response.body).to have_tag("h1", text: page3.title)
      end
    end
    context "for invalid path" do 
      before { get :show, { :page_path => "a/b/c" } }

      it { expect(response).to redirect_to root_path }
    end
  end

  describe "'add' page" do
    it "should be available from root" do
      get :new
      expect(response.body).to have_tag('h3',
       text: 'Add subpage for: Root page')
    end

    it "should be available from valid page" do
      get :new, { :page_path => "a/b/c" }
      expect(response.body).to redirect_to root_path
    end
  end

  describe "create new page" do
    context "with valid data" do
      it "should add new page" do
        expect do
          post :create, { page: { name: "new_page1", title: "new_page1" } }
        end.to change(Page, :count).by(1)
      end

      it "should convert unformatted text to htm" do
        post :create, { page: { name: "new_page22", title: "new_page2",
          content: "**[bold]**\\\\[italic]\\\\((n1/n2/n3 link))" } }
        expect(Page.last.content).to have_tag('b', text: "bold")
        expect(Page.last.content).to have_tag('i', text: "italic")
        expect(Page.last.content).to have_tag('a',
          :with => { :href => "n1/n2/n3" }, :text => "link")
      end
    end

    context "with invalid data" do
      it "should not add page" do
        expect do
          post :create, { page: { name: "", title: "" } }
        end.to_not change(Page, :count)
      end
    end
  end

  describe "updating page" do
    context "with valid data" do
      it "should change page title" do
        expect do
          post :update, { id: page1.id, page: { title: "a" } }
        end.to change{ page1.reload.title }.to("a")
      end
    end

    context "with invalid data" do
      it "should not change page" do
        expect do
          post :update, { id: page1.id,  page: { title: "" } }
        end.to_not change{ page1.title }
      end

      it "should show error" do
        expect do 
          post(:update, {}) 
        end.to raise_error ActionController::ParameterMissing
      end
    end

    context "with unformatted text" do
      before do
        post :update, { id: page1.id,
          page: { title: "updated",
            content: "**[bold]**\\\\[italic]\\\\((n1/n2/n3 link))" } }
      end

      it "should convert unformatted text to html" do
        expect(page1.reload.content).to have_tag('b', text: "bold")
        expect(page1.reload.content).to have_tag('i', text: "italic")
        expect(page1.reload.content).to have_tag('a',
          :with => { :href => "n1/n2/n3" }, :text => "link")
      end
    end
  end

  describe "edit page" do
    context "for valid path" do
      before do 
        page3.update_attribute(:content,
         "<b>bold</b> <i>italic</i> <a href=\"n1/n2/n3\">link</a>")
        get :edit, { page_path: page3.path } 
      end
      it "should convert content to unformatted view" do
        expect(response.body).to have_content("**[bold]** \\\\[italic]\\\\"<<
          " ((n1/n2/n3 link))")
      end
    end
    context "for invalid path" do 
      before { get :edit, { :page_path => "a/b/c" } }
      it { expect(response).to redirect_to root_path }
    end
    context "for empty path" do 
      before { get :edit, { :page_path => "" } }
      it { expect(response).to redirect_to root_path }
    end
  end
end
