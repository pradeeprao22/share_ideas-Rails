class AddFrontToPost < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :frontend, :string
  end
end
