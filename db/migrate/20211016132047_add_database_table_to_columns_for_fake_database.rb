class AddDatabaseTableToColumnsForFakeDatabase < ActiveRecord::Migration[6.1]
  def change
    add_column :columns_for_fake_databases, :database_table_id, :string
  end
end