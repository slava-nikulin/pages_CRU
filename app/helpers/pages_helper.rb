module PagesHelper
  def page_path_title(path)
    if path.nil? || path.empty?
      "Root page"
    else
      "#{path} page"
    end
  end

  def get_sub_tree(page)
    if page.name.nil?
      return "<ul>#{sub_tree_without_root(page)}</ul>" 
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

  def sub_tree_without_root(page)
    html = ""
    page.sub_pages.each do |sub_page|
      html << "<li>#{sub_page.name}<ul>#{sub_tree_without_root(sub_page)}</ul></li>"
    end
    return html
  end
end
