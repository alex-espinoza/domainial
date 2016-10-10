// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  $('.track-domain').on('click', function(e) {
    var $this = $(this);
    $this.attr('disabled', 'disabled');
    var word = $this.val();
    var tld = $this.siblings('select').val();
    var data = {
                 'wanted_domain': {
                   'name': word,
                   'tld': tld
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

      setTimeout(function() {
        $this.toggleClass('btn-secondary btn-success');
        $this.removeAttr('disabled');
      }, 1500);
    })
    .fail(function(response) {
      $this.toggleClass('btn-secondary btn-warning');

      setTimeout(function() {
        $this.toggleClass('btn-secondary btn-warning');
        $this.removeAttr('disabled');
      }, 1500);
    })
  });
});
