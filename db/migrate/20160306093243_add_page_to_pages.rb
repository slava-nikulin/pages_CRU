class AddPageToPages < ActiveRecord::Migration
  def change
    add_reference(:pages, :parent_page, references: :pages, index: true)
    add_foreign_key :pages, :pages, column: :parent_page_id, on_delete: :cascade
  end
end
