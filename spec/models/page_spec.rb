require 'rails_helper'

RSpec.describe Page, type: :model do
  before do
    @page = Page.new(name: "Example page", title: "example page title")
  end

  subject { @page }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:content) }
  it { is_expected.to respond_to(:parent_page) }
  it { is_expected.to respond_to(:sub_pages) }
  it { is_expected.to be_valid }

  describe "with empty name" do
    before { @page.name = "" }
    it { is_expected.not_to be_valid }
  end

  describe "with empty title" do
    before { @page.title = "" }
    it { is_expected.not_to be_valid }
  end

  describe "with name with non-word characters" do
    before { @page.name = "!!!  !***" }
    it { is_expected.not_to be_valid }
  end

  describe "with name with russian characters" do
    before { @page.name = "444asdSd_йДДййй_" }
    it { is_expected.to be_valid }
  end

  describe "that has two subpages with same name" do
    before do
      @page.sub_pages.build(:title => "t1", :name => "subpage_name")
      @page.sub_pages.build(:title => "t2", :name => "subpage_name")
    end
    it { is_expected.not_to be_valid }
  end

  describe "cannot have sibling with same name" do
    let!(:page1) { FactoryGirl.build(:page, name: @page.name ) }
    before do
      @page.save
    end
    it { expect(page1).not_to be_valid }
  end

  describe "subpage" do
    let!(:page1) { FactoryGirl.create(:page) }
    let!(:page2) { FactoryGirl.create(:page, parent_page_id: page1.id) }
    let!(:page3) { FactoryGirl.create(:page, parent_page_id: page2.id) }

    it "should have valid hierarchical url path" do
      expect(page3.path).to eq "#{page1.name}/#{page2.name}/#{page3.name}"
    end
  end

  describe "with reserved name" do
    before { @page.name = "add" }
    it { is_expected.not_to be_valid }

    describe "subpages" do
      let!(:page1) { FactoryGirl.build(:page, name: "edit" ) }
      before do 
        @page.name = "test" 
        @page.sub_pages << page1
      end
      it { is_expected.not_to be_valid }
    end
  end
end
