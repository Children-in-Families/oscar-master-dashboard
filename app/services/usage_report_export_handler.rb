class UsageReportExportHandler
  include ApplicationHelper

  def self.call(collection, month, year, file_name)
    new(collection, month, year, file_name).call
  end

  attr_reader :collection, :date, :file_name

  def initialize(collection, month, year, file_name)
    @collection = collection
    @date = Date.new(year.to_i, month.to_i)
    @file_name = file_name
  end


  def call
    Axlsx::Package.new do |p|
      add_cases_sheet(p)
      synced_cases_sheet(p)
      cross_referral_sheet(p)
      cross_referral_to_primero(p)
      cross_referral_from_primero(p)
      vulnerability_and_service_type(p)

      p.serialize(file_name)
    end
  end

  private

  def cross_referral_from_primero(package)
    headers = [
      'NGO Name',
      '# of client referred',
      'Adult female without disability',
      'Adult female with disability',
      'Adult male without disability',
      'Adult male with disability',
      'Child female without disability',
      'Child female with disability',
      'Child male without disability',
      'Child male with disability',
      'Other',
      'Client\'s current province'
    ]

    package.workbook.add_worksheet(name: "Referral from Primero #{ date.month }-#{date.year}") do |sheet|
      sheet.add_row headers
      collection.each do |report|
        sheet.add_row [
          report.organization_name,
          report.cross_referral_from_primero_cases['total'],
          report.cross_referral_from_primero_cases['adult_female_without_disability'],
          report.cross_referral_from_primero_cases['adult_female_with_disability'],
          report.cross_referral_from_primero_cases['adult_male_without_disability'],
          report.cross_referral_from_primero_cases['adult_male_with_disability'],
          report.cross_referral_from_primero_cases['child_female_without_disability'],
          report.cross_referral_from_primero_cases['child_female_with_disability'],
          report.cross_referral_from_primero_cases['child_male_without_disability'],
          report.cross_referral_from_primero_cases['child_male_with_disability'],
          report.cross_referral_from_primero_cases['other'],
          report.cross_referral_from_primero_cases['provinces'].uniq.join(', '),
        ]
      end
    end
  end

  def cross_referral_to_primero(package)
    headers = [
      'NGO Name',
      '# of client referred',
      'Adult female without disability',
      'Adult female with disability',
      'Adult male without disability',
      'Adult male with disability',
      'Child female without disability',
      'Child female with disability',
      'Child male without disability',
      'Child male with disability',
      'Other',
      'Client\'s current province'
    ]

    package.workbook.add_worksheet(name: "Referral to Primero #{ date.month }-#{date.year}") do |sheet|
      sheet.add_row headers
      collection.each do |report|
        sheet.add_row [
          report.organization_name,
          report.cross_referral_to_primero_cases['total'],
          report.cross_referral_to_primero_cases['adult_female_without_disability'],
          report.cross_referral_to_primero_cases['adult_female_with_disability'],
          report.cross_referral_to_primero_cases['adult_male_without_disability'],
          report.cross_referral_to_primero_cases['adult_male_with_disability'],
          report.cross_referral_to_primero_cases['child_female_without_disability'],
          report.cross_referral_to_primero_cases['child_female_with_disability'],
          report.cross_referral_to_primero_cases['child_male_without_disability'],
          report.cross_referral_to_primero_cases['child_male_with_disability'],
          report.cross_referral_to_primero_cases['other'],
          report.cross_referral_to_primero_cases['provinces'].uniq.join(', '),
        ]
      end
    end
  end

  def cross_referral_sheet(package)
    headers = [
      'NGO Name',
      '# of client referred',
      'Adult female without disability',
      'Adult female with disability',
      'Adult male without disability',
      'Adult male with disability',
      'Child female without disability',
      'Child female with disability',
      'Child male without disability',
      'Child male with disability',
      'Other',
      'Agency name received the case'
    ]

    package.workbook.add_worksheet(name: "Referral within OSCaR #{ date.month }-#{date.year}") do |sheet|
      sheet.add_row headers
      collection.each do |report|
        sheet.add_row [
          report.organization_name,
          report.cross_referral_cases['total'],
          report.cross_referral_cases['adult_female_without_disability'],
          report.cross_referral_cases['adult_female_with_disability'],
          report.cross_referral_cases['adult_male_without_disability'],
          report.cross_referral_cases['adult_male_with_disability'],
          report.cross_referral_cases['child_female_without_disability'],
          report.cross_referral_cases['child_female_with_disability'],
          report.cross_referral_cases['child_male_without_disability'],
          report.cross_referral_cases['child_male_with_disability'],
          report.cross_referral_cases['other'],
          report.cross_referral_cases['agencies'].uniq.join(', ')
        ]
      end
    end
  end

  def synced_cases_sheet(package)
    headers = [
      'NGO Name',
      'Sign-up date',
      'Current sharing',
      'Total cases synced',
      'Adult female without disability',
      'Adult female with disability',
      'Adult male without disability',
      'Adult male with disability',
      'Child female without disability',
      'Child female with disability',
      'Child male without disability',
      'Child male with disability',
      'Other'
    ]

    package.workbook.add_worksheet(name: "Synced cases #{ date.month }-#{date.year}") do |sheet|
      sheet.add_row headers
      collection.each do |report|
        sheet.add_row [
          report.organization_name,
          format_value(report.synced_cases['signed_up_date']),
          format_value(report.synced_cases['current_sharing']),
          report.synced_cases['total'],
          report.synced_cases['adult_female_without_disability'],
          report.synced_cases['adult_female_with_disability'],
          report.synced_cases['adult_male_without_disability'],
          report.synced_cases['adult_male_with_disability'],
          report.synced_cases['child_female_without_disability'],
          report.synced_cases['child_female_with_disability'],
          report.synced_cases['child_male_without_disability'],
          report.synced_cases['child_male_with_disability'],
          report.synced_cases['other']
        ]
      end
    end
  end

  def add_cases_sheet(package)
    headers = [
      'NGO Name',
      '# Login',
      'Total client',
      'Adult female without disability',
      'Adult female with disability',
      'Adult male without disability',
      'Adult male with disability',
      'Child female without disability',
      'Child female with disability',
      'Child male without disability',
      'Child male with disability',
      'Other'
    ]

    package.workbook.add_worksheet(name: "Added cases #{date.month}-#{date.year}") do |sheet|
      sheet.add_row headers

      collection.each do |report|
        sheet.add_row [
          report.organization_name,
          report.added_cases['login_per_month'],
          report.added_cases['total'],
          report.added_cases['adult_female_without_disability'],
          report.added_cases['adult_female_with_disability'],
          report.added_cases['adult_male_without_disability'],
          report.added_cases['adult_male_with_disability'],
          report.added_cases['child_female_without_disability'],
          report.added_cases['child_female_with_disability'],
          report.added_cases['child_male_without_disability'],
          report.added_cases['child_male_with_disability'],
          report.added_cases['other']
        ]
      end
    end
  end

  def vulnerability_and_service_type(package)
    headers = [
      'NGO Name',
      'ID',
      'Gender',
      'Status',
      'Age',
      'Created Date',
      'Current Province',
      'Type of Services',
      'កុមារ​មានជំងឺរ៉ាំរ៉ែ និង/ឬ​ពិការភាព / History of disability and/or illness',
      'ការបង្កទុក្ខទោស​ និង​ការ​កេង​ប្រវ័ញ្ច / History of Harm',
      'ការ​បំពានគ្រឿង​ញៀនឬគ្រឿង​ស្រវឹង និង​ល្បែងស៉ីសង / History of high-risk behaviours',
      'Is the child at-risk of family separation?',
      'ការបែកចេញ​ពី​គ្រួសារ - Reason for Family Separation'
    ]
    package.workbook.add_worksheet(name: "Vulnerability cases #{date.month}-#{date.year}") do |sheet|
      sheet.add_row headers
      collection.map(&:vulnerability).each do |report|
        next if report.blank?

        report.each do |record|
          sheet.add_row [
            record['ngo_name'],
            record['client_id'],
            record['client_gender'],
            record['client_status'],
            record['client_age'],
            record['client_created_date'],
            record['current_province'],
            record['type_of_service'],
            record['កុមារ​មានជំងឺរ៉ាំរ៉ែ និង/ឬ​ពិការភាព / History of disability and/or illness'],
            record['ការបង្កទុក្ខទោស​ និង​ការ​កេង​ប្រវ័ញ្ច / History of Harm'],
            record['ការ​បំពានគ្រឿង​ញៀនឬគ្រឿង​ស្រវឹង និង​ល្បែងស៉ីសង / History of high-risk behaviours'],
            record['Is the child at-risk of family separation?'],
            record['ការបែកចេញ​ពី​គ្រួសារ - Reason for Family Separation']
          ]
        end
      end
    end
  end
end
