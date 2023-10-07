require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import 'jquery-ui/ui/widgets/datepicker';
import "@selectize/selectize";

import Chart from 'chart.js/auto';
import ChartDataLabels from 'chartjs-plugin-datalabels';
Chart.register(ChartDataLabels);

import jQuery from "jquery";
global.$ = jQuery;

require("bootstrap");

$(document).on("turbolinks:load", function() {
  $(".flatpickr").datepicker({
    changeMonth: true,
    changeYear: true,
    dateFormat: "yy-mm-dd"
  });
  
  $('.dropdown-toggle').dropdown();
  $("select").selectize({});

  deleteInstanceHandler();

  if ($("#clients-status .chart-holder").length > 0) {
    initChartjs();
    initClientsAgeChart();
    initPrimeroChart();
    initNGOChart();
  }

})

$(document).on('turbolinks:before-cache', function() {
  $('.select').each(function() {
    if (this.selectize) {
      this.selectize.destroy();
    }
  });
});


function deleteInstanceHandler() {
  $("input[name='instance_name'").on("keyup", function() {
    var actualInstanceName = $(this).closest("form").find(".instance_name").text();
    var deleteButton = $(this).closest("form").find(".submit-btn");

    if ($(this).val() == actualInstanceName) {
      deleteButton.removeClass("disabled");
    } else {
      deleteButton.addClass("disabled");
    }
  })
}


function initChartjs () {
  const config = {
    type: 'pie',
    data: $("#clients-status .chart-holder").data("source").client_status,
    options: {
      responsive: true,
      plugins: {
        legend: {
          position: 'top',
        },
        datalabels: {
          display: true,
          color: '#fff',
          font: {
            size: 12,
          }
        }
      }
    },
  };

  var ctx = $('#clients-status .chart-holder')[0].getContext('2d');
  var myChart = new Chart(ctx, config);
}

function initClientsAgeChart() {
  var data = $("#clients-age-gender .chart-holder").data("source").client_age_gender
  var max = Math.max.apply(Math, data.datasets[0].data);

  const config = {
    type: 'bar',
    data: data,
    options: {
      responsive: true,
      scales: {
        y: {
          max: max + (max >= 10 ? max/10 : 1),
        }
      },
      plugins: {
        legend: {
          display: false,
        },
        datalabels: {
          display: true,
          color: '#000',
          clip: true,
          align: 'end',
          anchor: 'end',
          font: {
            size: 12,
          }
        }
      }
    },
  };

  var ctx = $('#clients-age-gender .chart-holder')[0].getContext('2d');
  var myChart = new Chart(ctx, config);
}

function initPrimeroChart() {
  var data = $("#cases-synced-to-primero .chart-holder").data("source").case_sync_to_primero
  var max = Math.max.apply(Math, data.datasets[0].data);

  const config = {
    type: 'bar',
    data: data,
    options: {
      responsive: true,
      scales: {
        y: {
          max: max + (max >= 10 ? max/10 : 1),
        }
      },
      plugins: {
        legend: {
          display: false,
        },
        datalabels: {
          display: true,
          clip: true,
          align: 'end',
          anchor: 'end',
          color: '#000',
          font: {
            size: 12,
          }
        }
      }
    },
  };

  var ctx = $('#cases-synced-to-primero .chart-holder')[0].getContext('2d');
  var myChart = new Chart(ctx, config);
}


function initNGOChart() {
  var data = $("#ngo-by-country .chart-holder").data("source").ngo_by_country
  var max1 = Math.max.apply(Math, data.datasets[0].data);
  var max2 = Math.max.apply(Math, data.datasets[1].data);
  var max = Math.max(max1, max2);

  const config = {
    type: 'bar',
    data: $("#ngo-by-country .chart-holder").data("source").ngo_by_country,
    options: {
      indexAxis: 'y',
      responsive: true,
      scales: {
        x: {
          max: max + (max >= 10 ? max/10 : 1),
        }
      },
      plugins: {
        legend: {
          position: 'top',
        },
        datalabels: {
          display: true,
          align: 'end',
          anchor: 'end',
          clip: true,
          color: '#000',
          font: {
            size: 12,
          }
        }
      }
    },
  };

  var ctx = $('#ngo-by-country .chart-holder')[0].getContext('2d');
  var myChart = new Chart(ctx, config);
}
