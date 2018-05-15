$(document).ready(function(){
  // Add smooth scrolling to all links
  $("a[href*='#']").on('click', function(event) {
    // Make sure this.hash has a value before overriding default behavior
    if (this.hash !== "" && this.hash !== "#carouselControls") {
      // Prevent default anchor click behavior
      event.preventDefault();

      // Store hash
      var hash = this.hash;

      // Using jQuery's animate() method to add smooth page scroll
      // The optional number (800) specifies the number of milliseconds it takes to scroll to the specified area
      $('html, body').animate({
        scrollTop: $(hash).offset().top
      }, 800, function(){

        // Add hash (#) to URL when done scrolling (default click behavior)
        window.location.hash = hash;
      });
    } // End if
  });

  $('button').mouseup(function() { this.blur() });
});

// slider
var view = $("#tslshow");
var move = "350px";
var sliderLimit = -2050 + screen.width;
var endLeft = -2400 + screen.width;
endLeft = endLeft.toString();
endLeft = endLeft.concat("px");

document.getElementById("leftArrow").style.display = 'none';

$("#rightArrow").click(function(){
    var currentPosition = parseInt(view.css("left"));
    if (currentPosition > sliderLimit) {
      view.stop(false,true).animate({left:"-="+move},{ duration: 400});
      document.getElementById("leftArrow").style.display = 'block';
    }
    else {
      view.stop(false,true).animate({left:endLeft},{duration: 400});
      document.getElementById("rightArrow").style.display = 'none';
    }

});

$("#leftArrow").click(function(){
    var currentPosition = parseInt(view.css("left"));
    if (currentPosition < -350) {
      view.stop(false,true).animate({left:"+="+move},{ duration: 400});
      document.getElementById("rightArrow").style.display = 'block';
    }
    else {
      view.stop(false,true).animate({left:"0px"}, {duration:400});
      document.getElementById("leftArrow").style.display = 'none';
    }
});
/*
var hoverTip = function {
  if ($(window).scrollTop > screen.height + 600) {

  }
}

setInterval(hoverTip,10);*/
