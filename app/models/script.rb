class Script < ActiveRecord::Base
  scope :not_replaced,  ->() { where(replaced_by: nil) }
  scope :deleted,  ->() { where(deleted: true) }
  scope :not_deleted,  ->() { where(deleted: false) }

  validates_presence_of :name, :interpreter, :content

  has_many :actions

  def replaced?
    replaced_by.present?
  end

  def replacement
    @replacement ||= Script.find(replaced_by)
  end
end
