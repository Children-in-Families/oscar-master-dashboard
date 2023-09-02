class SharedClient < ActiveRecord::Base
  self.table_name = 'shared.shared_clients'
  has_paper_trail
end
