class PagesController < ApplicationController
  before_action :page_path_validate, only: [:new, :create, :show, :edit]

  def index
    render "pages/index"
  end

  def show
    render "pages/show"
  end

  def new
    @page = Page.new
    @page.parent_page = @current_page
    render "pages/new"
  end

  def create
    new_page = Page.new(add_page_params)
    new_page.content = text_to_html(new_page.content)
    new_page.parent_page = @current_page
    if new_page.save
      redirect_to show_page_path(page_path: new_page.path)
    else
      @page = new_page
      render "pages/new"
    end
  end

  def edit
    @current_page.content = html_to_text(@current_page.content)
    render "pages/edit"
  end

  def update
    current_page = Page.find(params[:id])
    new_attributes = edit_page_params
    new_attributes[:content] = text_to_html(new_attributes[:content])
    if current_page.update_attributes(new_attributes)
      redirect_to show_page_path(page_path: current_page.path)
    else
      @current_page = current_page
      render "pages/edit"
    end
  end

  private
  def text_to_html(text)
    if text =~ /(\*\*\[(?:.*)\]\*\*)/
      text.gsub!(/(\*\*\[(?:.*)\]\*\*)/, "<b>#{$1[/\*\*\[(.*)\]\*\*/, 1].gsub('\\', '\\\\\\\\')}</b>")
    end
    if text =~ /(\\\\\[(?:.*)\]\\\\)/
      text.gsub!(/(\\\\\[(?:.*)\]\\\\)/, "<i>#{$1[/\\\\\[(.*)\]\\\\/, 1].gsub('\\', '\\\\\\\\')}</i>")
    end
    if text =~ /\(\(((?:(?:[^\/])*(?:\/|\s))*)(\[(?:.*)\])\)\)/
      text.gsub!(/\(\(((?:(?:[^\/])*(?:\/|\s))*)(\[(?:.*)\])\)\)/,
       "<a href='#{$1}'>#{$2}</a>")
    end
    text
  end

  def html_to_text(text)
    if text =~ /(<b>(?:.*)<\/b>)/
      text.gsub!(/(<b>(?:.*)<\/b>)/, "**[#{$1[/<b>(.*)<\/b>/, 1]}]**")
    end
    if text =~ /(<i>(?:.*)<\/i>)/
      text.gsub!(/(<i>(?:.*)<\/i>)/, "\\\\\\\\[#{$1[/<i>(.*)<\/i>/, 1]}]\\\\\\\\")
    end
    if text =~ /<a href="((?:(?:(?:[^\/"\[]))*(?:\/))*[^"]*)\".\[(.*)\]/
      text.gsub!(/<a href="((?:(?:(?:[^\/"\[]))*(?:\/))*[^"]*)\".\[(.*)\]/,
       "((#{$1} [#{$2}]))")
    end
    text
  end

  def page_path_validate
    return if params[:page_path].nil?
    current = previous = nil

    path_invalid = params[:page_path].split("/").select do |x|
      !x.empty? 
    end.any? do |name|
      current = Page.find_by(name: name, parent_page: previous)
      @current_page = previous = current
      current.nil?
    end
    redirect_to root_path if path_invalid
  end

  def add_page_params
    params.require(:page).permit(:name, :title, :content)
  end

  def edit_page_params
    params.require(:page).permit(:title, :content)
  end
end