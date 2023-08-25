class OrganizationMailer < ApplicationMailer
  def notify_organization_archived(organization, user)
    mail(
      to: AdminUser.admins.pluck(:email).join(', '),
      subject: "OSCaR MD: #{organization.full_name} was archived!",
      body: "Hello, \n\nThe instance #{organization.full_name} was archived by #{user.full_name} at #{organization.deleted_at.strftime("%Y-%m-%d %I:%M")}.\n\nThanks,\nOSCaR MD"
    )
  end

  def notify_organization_deleted(organization_name, user)
    mail(
      to: AdminUser.admins.pluck(:email).join(', '),
      subject: "OSCaR MD: #{organization_name} was deleted!",
      body: "Hello,\n\nThe instance #{organization_name} was permanently deleted by #{user.full_name} at #{Time.now.strftime("%Y-%m-%d %I:%M")}.\n\nThanks,\nOSCaR MD"
    )
  end
end
