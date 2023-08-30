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
          backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00FF00'],
          hoverBackgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00FF00']
        }
      ]
    }
  end

  def client_age_gender_data
    {
      labels: ['Adult female', 'Adult male', 'Child female', 'Child male', 'Other'],
      datasets: [
        {
          data: [300, 50, 100, 40, 120],
          backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00FF00', '#FF0000'],
          hoverBackgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#00FF00', '#FF0000']
        }
      ]
    }
  end

  def ngo_by_country_data
    {
      labels: ['USA', 'Canada', 'Mexico', 'Brazil', 'Argentina'],
      datasets: [
        {
          data: [30, 4, 2, 12, 8],
          backgroundColor: '#36A2EB',
          label: '# of NGO'
        },
        {
          data: [100, 50, 100, 40, 120],
          backgroundColor: '#FFCE56',
          label: '# of Cases'
        }
      ]
    }
  end
end
