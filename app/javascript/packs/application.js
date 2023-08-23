require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import "@selectize/selectize";
import flatpickr from "flatpickr"; 

import jQuery from "jquery";
global.$ = jQuery;

require("bootstrap");

$(document).on("turbolinks:load", function() {
  $('.dropdown-toggle').dropdown();
  $(".flatpickr").flatpickr({});
  $("select").selectize({});

  deleteInstanceHandler();
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
