// Entry point for the build script in your package.json
console.log("file loaded")

import "jquery"
import $ from "jquery"
import jQuery from "jquery"
import "@hotwired/turbo-rails"
import "popover"
// import toastr from "toastr" 
import "@rails/actioncable"
// Import Font Awesome styles
import "@fortawesome/fontawesome-free/css/all.css"
// import "@activeadmin/activeadmin"
// import "./testing"

import "./toastr"

import Turbolinks from "turbolinks"
Turbolinks.start()

import Rails from "@rails/ujs"
Rails.start()

import "codemirror"
import "./codemirror_custom"
// import "./channels"

// console.log(toastr)
// global.$ = global.jQuery = $;
// global.$ = global.jQuery = jQuery;

window.$ = window.jQuery = require("jquery");

// window.$ = toastr.options
import "./user_search"