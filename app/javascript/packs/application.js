require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
require("channels");

import 'jquery-ui/ui/widgets/datepicker';
import "@selectize/selectize";
import Chart from 'chart.js/auto';
import ChartDataLabels from 'chartjs-plugin-datalabels';
import jQuery from "jquery";
require("bootstrap");

global.$ = jQuery;
Chart.register(ChartDataLabels);

$(document).on("turbolinks:load", function () {
  initUIComponents();
  initCharts();

  deleteInstanceHandler();
});

$(document).on('turbolinks:before-cache', function () {
  destroySelectizeInstances();
});

function initUIComponents() {
  $(".flatpickr").datepicker({
    changeMonth: true,
    changeYear: true,
    dateFormat: "yy-mm-dd"
  });

  $('.dropdown-toggle').dropdown();
  $("select").selectize({});
}

function destroySelectizeInstances() {
  $('.select').each(function () {
    if (this.selectize) {
      this.selectize.destroy();
    }
  });
}

function deleteInstanceHandler() {
  $("input[name='instance_name']").on("keyup", function () {
    const actualInstanceName = $(this).closest("form").find(".instance_name").text();
    const deleteButton = $(this).closest("form").find(".submit-btn");

    $(this).val() === actualInstanceName ? deleteButton.removeClass("disabled") : deleteButton.addClass("disabled");
  });
}

function initCharts() {
  initChartjs();
  initClientsAgeChart();

  if ($(".pie-chart-wrapper .chart-holder").length > 0) {
    initPrimeroChart();
    initNGOChart();
  }
}

function initChartjs() {
  const pieChartHolders = $(".pie-chart-wrapper .chart-holder");

  pieChartHolders.each(function () {
    const data = $(this).data("source").client_status;
    createPieChart(this, data);
  });

  const caseByAges = $('.chart-case-by-age');

  caseByAges.each(function () {
    const data = $(this).data("source");
    const indexAxis = $(this).data("indexAxis");
    createBarChart(this, data, indexAxis);
  });
}

function createPieChart(element, data) {
  const config = {
    type: 'pie',
    data: data,
    options: {
      responsive: true,
      plugins: {
        legend: { position: 'bottom' },
        datalabels: {
          display: context => context.dataset.data[context.dataIndex] > 0,
          anchor: 'end',
          align: 'start',
          color: '#fff',
          font: { size: 12 }
        }
      }
    }
  };
  const ctx = $(element)[0].getContext('2d');
  new Chart(ctx, config);
}

function createBarChart(element, data, indexAxis = 'x') {
  const config = {
    type: 'bar',
    data: data,
    options: {
      indexAxis: indexAxis,
      responsive: true,
      scales: {
        x: {
          stacked: true,
          beginAtZero: true,
          barPercentage: 0.5,
          categoryPercentage: 0.5
        },
        y: {
          stacked: true,
          beginAtZero: true,
          barPercentage: 0.5,
          categoryPercentage: 0.5
        }
      },
      plugins: {
        legend: { position: 'bottom' },
        datalabels: {
          display: context => context.dataset.data[context.dataIndex] > 0,
          anchor: 'end',
          align: 'start',
          color: '#000',
          font: { size: 10 }
        }
      }
    }
  };
  const ctx = $(element)[0].getContext('2d');
  new Chart(ctx, config);
}

function initClientsAgeChart() {
  const chartsContainer = $("#clients-age-gender .chart-holder");

  chartsContainer.each(function () {
    const data = $(this).data("source").client_age_gender;
    const max = Math.max(...data.datasets[0].data);
    createAgeGenderChart(this, data, max);
  });
}

function createAgeGenderChart(element, data, max) {
  const config = {
    type: 'bar',
    data: data,
    options: {
      responsive: true,
      scales: {
        x: { barThickness: 20, maxBarThickness: 40 },
        y: {
          max: max + (max >= 10 ? max / 10 : 1),
          beginAtZero: true,
          suggestedMax: 100
        }
      },
      plugins: {
        legend: { display: false },
        datalabels: {
          display: true,
          color: '#000',
          clip: true,
          align: 'end',
          anchor: 'end',
          font: { size: 12 }
        }
      }
    }
  };
  const ctx = $(element)[0].getContext('2d');
  new Chart(ctx, config);
}

function initPrimeroChart() {
  const data = $("#cases-synced-to-primero .chart-holder").data("source").case_sync_to_primero;
  const max = Math.max(...data.datasets[0].data);
  createBarChartWithMax("#cases-synced-to-primero .chart-holder", data, max);
}

function initNGOChart() {
  const data = $("#ngo-by-country .chart-holder").data("source").ngo_by_country;
  const max = Math.max(Math.max(...data.datasets[0].data), Math.max(...data.datasets[1].data));
  createBarChartWithMax("#ngo-by-country .chart-holder", data, max, 'y');
}

function createBarChartWithMax(selector, data, max, indexAxis = 'x') {
  const config = {
    type: 'bar',
    data: data,
    options: {
      indexAxis: indexAxis,
      responsive: true,
      scales: {
        [indexAxis === 'x' ? 'y' : 'x']: { max: max + (max >= 10 ? max / 10 : 1) }
      },
      plugins: {
        legend: { position: 'bottom' },
        datalabels: {
          display: true,
          align: 'end',
          anchor: 'end',
          clip: true,
          color: '#000',
          font: { size: 12 }
        }
      }
    }
  };
  const ctx = $(selector)[0].getContext('2d');
  new Chart(ctx, config);
}
