class AddFrontEndCssToPost < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :frontend_css, :text
  end
end
