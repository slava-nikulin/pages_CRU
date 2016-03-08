class PagesController < ApplicationController
  before_action :get_current_page_by_path, only: [:new, :create, :show, :edit]

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
    new_page.content_to_html
    new_page.parent_page = @current_page

    if new_page.save
      redirect_to show_page_path(page_path: new_page.path)
    else
      @page = new_page
      render "pages/new"
    end
  end

  def edit
    return redirect_to root_path if @current_page.nil?
    @current_page.content_to_text
    render "pages/edit"
  end

  def update
    params.require(:id)
    current_page = Page.find(params[:id])
    current_page.assign_attributes(edit_page_params)
    current_page.content_to_html

    if current_page.save
      redirect_to show_page_path(page_path: current_page.path)
    else
      @current_page = current_page
      render "pages/edit"
    end
  end

  private
  
  def get_current_page_by_path
    return if params[:page_path].nil?
    redirect_to root_path if Page.path_valid?(params[:page_path])
    @current_page = Page.get_page_by_path params[:page_path]
  end

  def add_page_params
    params.require(:page).permit(:name, :title, :content)
  end

  def edit_page_params
    params.require(:page).permit(:title, :content)
  end
end