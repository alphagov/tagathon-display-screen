"use strict";

var stats = {
  endpoint: function() {
    return "/realtime"
  },

  refresh: function() {
    $.get(stats.endpoint(), function(data) {
      stats.display(data);
    });
  },

  display: function(data) {
    var display_stats = [];

    for (var property in data) {
      if (data.hasOwnProperty(property)) {
        display_stats.push(stats.html_stat_box(property, data[property]));
      }
    }

    $("#stats").html(display_stats.join(""));
  },

  html_stat_box: function(stat_name, stat_value) {
    return "<div class=\"col-md-3\"><h2>" + stat_value + "</h2><p>" + stat_name + "</p></div>";
  },

  init: function() {
    stats.refresh();
    // Refresh every 60 seconds
    window.setInterval(stats.refresh, 60e3);
  }
}

stats.init();
