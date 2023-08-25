class GlobalIdentityOrganization < ApplicationRecord
  belongs_to :organization
  belongs_to :global_identity, class_name: 'GlobalIdentity', foreign_key: 'global_id', primary_key: :ulid
end
