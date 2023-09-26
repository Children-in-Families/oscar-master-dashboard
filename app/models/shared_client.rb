class SharedClient < ActiveRecord::Base
  self.table_name = 'shared.shared_clients'
  has_paper_trail

  scope :duplicate, -> { where(duplicate: true) }

  def local_name
    [local_given_name, local_family_name].select(&:present?).join(' ')
  end

  def en_name
    [given_name, family_name].select(&:present?).join(' ')
  end
end
