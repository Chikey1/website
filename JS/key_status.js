$(function() {
  window.keydown = {};

  function keyName(event) {
    return jQuery.hotkeys.specialKeys[event.which] ||
      String.fromCharCode(event.which).toLowerCase();
  }


  var ar=new Array(33,34,35,36,37,38,39,40);

  $('#game-container').keydown(function(e) {
    keydown[keyName(e)] = true;
    var key = e.which;
    if($.inArray(key,ar) > -1) {
        e.preventDefault();
        return false;
    }
    return true;
  });
  $('#game-container').keyup(function(e) {
    keydown[keyName(e)] = false;
    var key = e.which;
    if($.inArray(key,ar) > -1) {
        e.preventDefault();
        return false;
    }
    return true;
  });

/*
  $(document).bind("keydown", function(event) {
    keydown[keyName(event)] = true;
  });

  $(document).bind("keyup", function(event) {
    keydown[keyName(event)] = false;
  });*/

});
