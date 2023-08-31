class ChartDataConverter
  attr_reader :organizations

  def initialize(organizations)
    @organizations = organizations
  end

  def client_status_data
    {
      labels: ['Active', 'Accepted', 'Exited', 'Referred'],
      datasets: [
        {
          data: [
            organizations.sum{ |org| org.cache_count[:active_client] || 0 },
            organizations.sum{ |org| org.cache_count[:accepted_client] || 0 },
            organizations.sum{ |org| org.cache_count[:exited_client] || 0},
            organizations.sum{ |org| org.cache_count[:referred_count] || 0 }
          ],
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
            organizations.sum{ |org| org.cache_count[:adult_female] || 0 },
            organizations.sum{ |org| org.cache_count[:adult_male] || 0 },
            organizations.sum{ |org| org.cache_count[:child_female] || 0 },
            organizations.sum{ |org| org.cache_count[:child_male] || 0 },
            organizations.sum{ |org| org.cache_count[:without_age_nor_gender] || 0 },
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
            organizations.sum{ |org| org.cache_count[:cases_synced_to_primero][:adult_female] || 0 },
            organizations.sum{ |org| org.cache_count[:cases_synced_to_primero][:adult_male] || 0 },
            organizations.sum{ |org| org.cache_count[:cases_synced_to_primero][:child_female] || 0 },
            organizations.sum{ |org| org.cache_count[:cases_synced_to_primero][:child_male] || 0 },
            organizations.sum{ |org| org.cache_count[:cases_synced_to_primero][:without_age_nor_gender] || 0 },
          ],
          backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00cc99', '#FF0000'],
          hoverBackgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00cc99', '#FF0000']
        }
      ]
    }
  end

  def ngo_by_country_data
    by_countries = organizations.group_by(&:country)

    {
      labels: by_countries.keys.map(&:titleize),
      datasets: [
        {
          data: by_countries.map{ |_country, organizations| organizations.size },
          backgroundColor: '#36A2EB',
          label: '# of NGO'
        },
        {
          data: by_countries.map{ |_country, organizations| organizations.sum{ |org| org.cache_count[:active_client] || 0 } },
          backgroundColor: '#FFCE56',
          label: '# of Active cases'
        }
      ]
    }
  end
end
