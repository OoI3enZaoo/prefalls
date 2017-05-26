  $( document ).ready(function() {

      $('.fade-bouncein').bind('inview', function (event, visible) {
          if (visible == true) {
              $(this).addClass('animated bounceIn');
          } else {
              $(this).removeClass('animated bounceIn');
          }
      });
      
      $('.fade-right').bind('inview', function (event, visible) {
          if (visible == true) {
              $(this).addClass('animated fadeInRight');
          } else {
              $(this).removeClass('animated fadeInRight');
          }
      });

      $('.fade-Left').bind('inview', function (event, visible) {
          if (visible == true) {
              $(this).addClass('animated fadeInLeft');
          } else {
              $(this).removeClass('animated fadeInLeft');
          }
      });
      
      $('.fade-Up').bind('inview', function (event, visible) {
          if (visible == true) {
              $(this).addClass('animated fadeInUp');
          } else {
              $(this).removeClass('animated fadeInUp');
          }
      });
      
});