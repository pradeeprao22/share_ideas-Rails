class AddReciverIdToNotification < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :reciver_id, :integer
  end
end
