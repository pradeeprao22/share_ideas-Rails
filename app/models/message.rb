class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user
  validates_presence_of :body, :conversation_id, :user_id

  scope :new_messages, -> { where('created_at > ?', 1.day.ago) }
end
