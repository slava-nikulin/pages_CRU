FactoryGirl.define do
  factory :page, class: Page do
    sequence(:name)  { |n| "Page_#{n}" }
    sequence(:title) { |n| "Title#{n}"}
    sequence(:content) { |n| "Content#{n}"}
    parent_page_id nil
  end
end