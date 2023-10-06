class ReleaseNote < ActiveRecord::Base
  self.table_name = 'public.relase_notes'

  validates :content, presence: true

  after_commit :create_notifications

  ransacker :created_date do
    Arel.sql('date(public.relase_notes.created_at)')
  end

  private

  def create_notifications
    return if destroyed?
    return unless published?

    Organization.active.without_shared.each do |organization|
      Organization.switch_to(organization.short_name)

      User.find_each do |user|
        Notification.create(
          key: 'relase_note',
          user: user,
          notifiable: self
        )
      end
    end
  end
end
