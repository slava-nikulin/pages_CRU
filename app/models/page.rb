class Page < ActiveRecord::Base
  #regexes to find unformatted/formatted elements in text
  BOLD_TEXT_REGEX = /(\*\*\[(?:.*)\]\*\*)/
  BOLD_HTML_REGEX = /(<b>(?:.*)<\/b>)/
  ITALIC_TEXT_REGEX = /(\\\\\[(?:.*)\]\\\\)/
  ITALIC_HTML_REGEX = /(<i>(?:.*)<\/i>)/
  PAGE_LINK_TEXT_REGEX = /\(\(((?:[^\/]|[^\s])*)\s(.*)\)\)/
  PAGE_LINK_HTML_REGEX = /<a href=(?:"|')(.*)(?:"|')>(.*)<\/a>/

  belongs_to :parent_page, :class_name => "Page", 
    :foreign_key => "parent_page_id"
  has_many :sub_pages, :class_name => "Page", :foreign_key => "parent_page_id"

  VALID_NAME_REGEX = /[a-zA-Zа-яА-Я0-9_]/
  validates :name, presence: true, length: { maximum: 30 },
   format: { with: VALID_NAME_REGEX }
  validates :title, presence: true, length: { maximum: 30 }
  validate :name_cannot_be_equal_sibling_page_name,
   :subpages_names_cannot_be_equal, :name_should_not_be_reserved

  #path from root to page i.e. "n1/n2/n3"
  def path(page = self)
    page.parent_page.nil? ? page.name :
                           "#{self.path(page.parent_page)}/#{page.name}"
  end

  #Convert unformatted content to html
  def content_to_html
    if content =~ BOLD_TEXT_REGEX
      content.gsub!(BOLD_TEXT_REGEX,
       "<b>#{$1[/\*\*\[(.*)\]\*\*/, 1].gsub('\\', '\\\\\\\\')}</b>")
    end
    if content =~ ITALIC_TEXT_REGEX
      content.gsub!(ITALIC_TEXT_REGEX,
       "<i>#{$1[/\\\\\[(.*)\]\\\\/, 1].gsub('\\', '\\\\\\\\')}</i>")
    end
    if content =~ PAGE_LINK_TEXT_REGEX
      content.gsub!(PAGE_LINK_TEXT_REGEX,
       "<a href='#{$1}'>#{$2}</a>")
    end
  end

  #Convert html content to unformatted text
  def content_to_text
    if content =~ BOLD_HTML_REGEX
      content.gsub!(/(<b>(?:.*)<\/b>)/, "**[#{$1[/<b>(.*)<\/b>/, 1]}]**")
    end
    if content =~ ITALIC_HTML_REGEX
      content.gsub!(ITALIC_HTML_REGEX,
       "\\\\\\\\[#{$1[/<i>(.*)<\/i>/, 1]}]\\\\\\\\")
    end
    if content =~ PAGE_LINK_HTML_REGEX
      content.gsub!(PAGE_LINK_HTML_REGEX, "((#{$1} #{$2}))")
    end
  end

  #return page by string path
  def Page.get_page_by_path(path)
    current = previous = nil

    path.split("/").select do |x|
      !x.empty? 
    end.each do |name|
      current = Page.find_by(name: name, parent_page: previous)
      previous = current
    end
    current
  end

  def Page.path_valid?(path)
    current = previous = nil

    path.split("/").select do |x|
      !x.empty? 
    end.any? do |name|
      current = Page.find_by(name: name, parent_page: previous)
      previous = current
      current.nil?
    end
  end

  private
  def name_cannot_be_equal_sibling_page_name
    if (parent_page.nil? &&
       Page.where(parent_page: nil).any?{ |p| p.name == self.name &&
        self.id != p.id }) || 
       (!parent_page.nil? &&
       parent_page.sub_pages.any?{ |p| p.name == self.name &&
        self.id != p.id })

        errors.add(:name, "can't be the same as one of siblings page")
    end
  end

  def subpages_names_cannot_be_equal
    if sub_pages.group_by{ |e| e.name }
      .select{ |k, v| v.size > 1 }
      .map(&:first).size > 0

      errors.add(:name, "can't be the same as one of siblings page")
    end
  end

  def name_should_not_be_reserved
    if name == "add" || name == "edit"
      errors.add(:name, "should not be equal to reserved names 'add', 'edit'")
    end
  end
end
