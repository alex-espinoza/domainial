// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  $('.track-domain').on('click', function(e) {
    var $this = $(this);
    $this.attr('disabled', 'disabled');
    var word = $this.val();
    var data = {
                 'wanted_domain': {
                   'name': word
                 }
               };

    $.ajax({
      contentType: 'application/json',
      data: JSON.stringify(data),
      dataType: 'json',
      method: 'POST',
      url: '/api/wanted_domains/create'
    })
    .done(function(response) {
      $this.toggleClass('btn-secondary btn-success');
      $this.text('Now Tracking');
    })
    .fail(function(response) {
      $this.toggleClass('btn-secondary btn-warning');
      $this.text('Already Tracked');
    })
  });
});
