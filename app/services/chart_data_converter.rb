class ChartDataConverter
  attr_reader :reports

  def initialize(reports)
    @reports = reports
  end

  def client_status_data
    {
      labels: ['Active', 'Inactive', 'Exited', 'Referred'],
      datasets: [
        {
          data: [300, 50, 100, 40],
          backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00cc99'],
          hoverBackgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00cc99']
        }
      ]
    }
  end

  def client_age_gender_data
    {
      labels: ['Adult female', 'Adult male', 'Child female', 'Child male', 'Other'],
      datasets: [
        {
          data: [
            reports.sum{ |report| report.added_cases['adult_female'] },
            reports.sum{ |report| report.added_cases['adult_male'] },
            reports.sum{ |report| report.added_cases['child_female'] },
            reports.sum{ |report| report.added_cases['child_male'] },
          ],
          backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00cc99', '#FF0000'],
          hoverBackgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00cc99', '#FF0000']
        }
      ]
    }
  end

  def primero_data
    {
      labels: ['Adult female', 'Adult male', 'Child female', 'Child male', 'Other'],
      datasets: [
        {
          data: [
            reports.sum{ |report| report.cross_referral_to_primero_cases['adult_female'] },
            reports.sum{ |report| report.cross_referral_to_primero_cases['adult_male'] },
            reports.sum{ |report| report.cross_referral_to_primero_cases['child_female'] },
            reports.sum{ |report| report.cross_referral_to_primero_cases['child_male'] },
          ],
          backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00cc99', '#FF0000'],
          hoverBackgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00cc99', '#FF0000']
        }
      ]
    }
  end

  def ngo_by_country_data
    by_countries = reports.group_by{ |report| report.organization.country }

    {
      labels: by_countries.keys.map(&:titleize),
      datasets: [
        {
          data: by_countries.map{ |_country, reports| reports.map(&:organization_id).uniq.count },
          backgroundColor: '#36A2EB',
          label: '# of NGO'
        },
        {
          data: by_countries.map{ |_country, reports| reports.sum{ |report| report.synced_cases['total'] } },
          backgroundColor: '#FFCE56',
          label: '# of Cases'
        }
      ]
    }
  end
end
