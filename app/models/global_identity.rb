class GlobalIdentity < ApplicationRecord
  self.primary_key = "ulid"

  has_many :organizations, through: :global_identity_organizations
  has_many :global_identity_organizations, class_name: 'GlobalIdentityOrganization', foreign_key: 'global_id', dependent: :destroy
  has_many :external_system_global_identities, class_name: 'ExternalSystemGlobalIdentity', foreign_key: 'global_id', dependent: :destroy
end
