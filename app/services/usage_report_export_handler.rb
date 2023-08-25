class UsageReportExportHandler
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

    package.workbook.add_worksheet(name: "Referral from Primero #{ date.strftime('%B %Y') }") do |sheet|
      sheet.add_row headers
      collection.each do |report|
        sheet.add_row [
          report.organization.full_name,
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
          '',
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

    package.workbook.add_worksheet(name: "Referral to Primero #{ date.strftime('%B %Y') }") do |sheet|
      sheet.add_row headers
      collection.each do |report|
        sheet.add_row [
          report.organization.full_name,
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
          '',
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

    package.workbook.add_worksheet(name: "Referral within OSCaR #{ date.strftime('%B %Y') }") do |sheet|
      sheet.add_row headers
      collection.each do |report|
        sheet.add_row [
          report.organization.full_name,
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
          report.cross_referral_cases['agencies'].join(', ')
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

    package.workbook.add_worksheet(name: "Synced cases #{ date.strftime('%B %Y') }") do |sheet|
      sheet.add_row headers
      collection.each do |report|
        sheet.add_row [
          report.organization.full_name,
          '',
          '',
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

    package.workbook.add_worksheet(name: "Added cases #{ date.strftime('%B %Y') }") do |sheet|
      sheet.add_row headers

      collection.each do |report|
        sheet.add_row [
          report.organization.full_name,
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
end
