class Page < ActiveRecord::Base
  belongs_to :parent_page, :class_name => "Page", 
    :foreign_key => "parent_page_id"
  has_many :sub_pages, :class_name => "Page", :foreign_key => "parent_page_id"

  VALID_NAME_REGEX = /[\wа-яА-Я]/
  validates :name, presence: true, length: { maximum: 30 },
   format: { with: VALID_NAME_REGEX }
  validates :title, presence: true, length: { maximum: 30 }

  def path(page = self)
    page.parent_page.nil? ? page.name :
                           "#{self.path(page.parent_page)}/#{page.name}"
  end
end
