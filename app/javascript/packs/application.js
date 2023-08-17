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
})
