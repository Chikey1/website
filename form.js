$('form').submit(function(e) {
  e.preventDefault();
  var $this = $(this);
  var $btn = $this.find("button.btn-submit");
  $.post(
    "https://script.google.com/macros/s/AKfycbwB-S6sb-QHQRaLN4q-lLpav39T6DcwQ-RGANd2OJJjAMvIuafK/exec", $(this).serialize()
  ).done(
    function() {
      $btn.text("SENT").css("background-color","#23f585");
      $this.find('[name]').val('');
      window.setTimeout(
        function() {
          $btn.addClass('hidden-text');
          window.setTimeout(function() { $btn.removeClass('hidden-text').text("SEND").css("background-color","#F5A623"); }, 1000)
        }, 3000);
    }
  ).fail(
    function() { $btn.text("ERROR"); $btn.css("background-color","#f52323")}
  ).always(
    function() {
      $btn.prop("disabled",false);
      $btn.removeClass('hidden-text');
    }
  );
  $btn.prop("disabled", true);
  $btn.addClass('hidden-text');
});
