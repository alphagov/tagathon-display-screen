"use strict";

var stats = {
  refresh: function(init) {
    stats.loading_overlay(true);
    $.get("/api/statistics", function(data) {
      stats.display(data);

      // Remove slick if this isn't the first refresh
      // since it will be re-added later on the new content.
      if (!init) {
        $("#stats").slick("unslick");
      }

      $("#stats").slick({
        autoplay: true,
        autoplaySpeed: 5000,
        arrows: false,
        draggable: false,
        swipe: false,
        touchMove: false
      });

      stats.loading_overlay(false);
    });
  },

  display: function(data) {
    var stats_display = [];
    var totals_display = "";
    var stats_group = [];
    var totals_group = [];
    var number_of_teams = data["stats"].length;

    // Stats by group
    for (var i = 0; i < number_of_teams; i++) {
      for (var property in data["stats"][i]["stats"]) {
        if (data["stats"][i]["stats"].hasOwnProperty(property)) {
          stats_group.push(stats.html_stat_box(property, data["stats"][i]["stats"][property]));
        }
      }

      stats_display.push(
        stats.html_stats_slide(
          stats.html_stats_group_name(data["stats"][i]["group_name"]),
          stats.html_stats_group_box(stats_group)
        )
      );

      stats_group = [];
    }

    // Totals
    for (var property in data["totals"]) {
      if (data["totals"].hasOwnProperty(property)) {
        totals_group.push(stats.html_stat_box(property, data["totals"][property]));
      }
    }

    totals_display = stats.html_stats_group_box(totals_group)

    $("#stats").html(stats_display.join(""));
    $("#totals").html(totals_display);
  },

  html_stats_slide: function(stats_group_name, stats_group) {
    return "<div>" + stats_group_name + stats_group + "</div>"
  },

  html_stats_group_name: function(stats_group_name) {
    return "<div class=\"row\"><div class=\"col-md-12\"><h2>" + stats_group_name + "</h2></div></div>";
  },

  html_stats_group_box: function(stats_group) {
    return "<div class=\"row\">" + stats_group.join("") + "</div>";
  },

  html_stat_box: function(stat_name, stat_value) {
    return "<div class=\"col-md-3\"><h3>" + stat_value + "</h3><p>" + stat_name + "</p></div>";
  },

  loading_overlay: function(show) {
    var loading_overlay = $("#loading");

    if (show) {
      loading_overlay.show();
    } else {
      loading_overlay.hide();
    }
  },

  init: function() {
    stats.refresh(true);
    // Refresh every 60 seconds
    window.setInterval(stats.refresh, 60e3);
  }
};

stats.init();
