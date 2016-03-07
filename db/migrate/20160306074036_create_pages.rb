class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name, index: true
      t.string :title
      t.text :content
      
      t.timestamps null: false
    end
  end
end
