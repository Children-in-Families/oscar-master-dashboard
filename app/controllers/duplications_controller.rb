class DuplicationsController < ApplicationController
  def index
    authorize :duplication

    respond_to do |format|
      format.html
      format.xlsx do
        filename = "tmp/duplicate-clients-#{Date.today.strftime("%Y-%m-%d")}.xlsx"
        Axlsx::Package.new do |p|
          p.workbook.add_worksheet(name: "Duplicate clients") do |sheet|
            sheet.add_row [
              'Client ID',
              'Local Name',
              'English Name',
              'Date of Birth',
              'Gender',
              'NGO Name',
              'Created Date',
              'Duplicate to NGO',
              'Duplicate to Client',
              'Duplicated Fields'
            ]

            Organization.active.without_shared.each do |organization|
              Organization.switch_to(organization.short_name)

              Client.duplicate.find_each do |client|
                sheet.add_row [
                  client.slug,
                  client.local_name,
                  client.en_name,
                  client.date_of_birth&.strftime('%Y-%m-%d'),
                  client.gender,
                  organization.full_name,
                  client.created_at&.strftime('%Y-%m-%d'),
                  client.duplicate_with['duplicated_with_ngo'],
                  client.duplicate_with['duplicated_with_client_id'],
                  client.duplicate_with['duplicate_fields'].join(', '),
                ]
              end
            end
          end
          p.serialize(filename)
        end

        send_file filename, disposition: :attachment
      end
    end
  end
end
