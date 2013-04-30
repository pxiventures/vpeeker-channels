//= require dataTables/jquery.dataTables

$(function() {

  $(".embed").click(function(e) {
    if ($(this).hasClass("disabled")) {
      $("#upgrade-modal").modal("show");
    } else {
      var iframecode = '<iframe style="width:400px;height:630px" src="' + $(this).attr('href') + '"></iframe>';
      $("#embed-info").modal("show")
        .find(".name").text($(this).attr("title")).end()
        .find("textarea").text(iframecode).end()
        .find(".example").html(iframecode).end();
    }
    e.preventDefault();
  });

  // Todo: Remove the copy-pasta.
  $("li a.moderate").click(function(e) {
    if ($(this).hasClass("disabled")) {
      $("#upgrade-modal").modal("show");
      e.preventDefault();
    }
  });

});
