module PagesHelper
  def page_path_title(path)
    if path.nil? || path.empty?
      "Root page"
    else
      "#{path} page"
    end
  end

  #Use this in views
  def get_sub_tree(page)
    if page.name.nil?
      if Page.count > 0
        return "<ul>#{sub_tree_without_root(page)}</ul>" 
      else
        return ""
    else
      return "#{sub_tree(page)}" 
    end
  end

  def sub_tree(page)
    html = "<ul><li>#{page.name}"
    page.sub_pages.each do |sub_page|
      html << "#{sub_tree(sub_page)}"
    end
    html << "</li></ul>"
  end

  #pages list for root page, 
  #it's different than list for normal page, unfortunatelly
  def sub_tree_without_root(page)
    html = ""
    page.sub_pages.each do |sub_page|
      if sub_page.sub_pages.any?
        html <<
         "<li>#{sub_page.name}<ul>#{sub_tree_without_root(sub_page)}</ul></li>"
      else
        html << "<li>#{sub_page.name}</li>"
      end
    end
    return html
  end
end
