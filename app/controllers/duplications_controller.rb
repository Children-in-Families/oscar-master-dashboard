class DuplicationsController < ApplicationController
  def index
    authorize :duplication
    
    respond_to do |format|
      format.html do
        @q = SharedClient.duplicate.page(params[:page]).per(50).ransack(params[:q])
        @clients = @q.result
      end

      format.xlsx do
        @q = SharedClient.duplicate.ransack(params[:q])
        @clients = @q.result

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

            @clients.each do |client|
              sheet.add_row [
                client.slug,
                client.local_name,
                client.en_name,
                client.date_of_birth&.strftime('%Y-%m-%d'),
                client.gender,
                client.ngo_name,
                client.client_created_at&.strftime('%Y-%m-%d'),
                client.duplicate_with['duplicated_with_ngo'],
                client.duplicate_with['duplicated_with_client_id'],
                client.duplicate_with['duplicate_fields'].join(', '),
              ]
            end
          end
          p.serialize(filename)
        end

        send_file filename, disposition: :attachment
      end
    end
  end
end
