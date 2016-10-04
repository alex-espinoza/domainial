// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  $('.interested-domain').on('click', function(e) {
    var $this = $(this);
    $this.attr('disabled', 'disabled');
    var id = $this.val();
    var data = {
                 'wanted_domain': {
                   'id': id
                 }
               };

    $.ajax({
      contentType: 'application/json',
      data: JSON.stringify(data),
      dataType: 'json',
      method: 'POST',
      url: '/api/wanted_domains/interested'
    })
    .done(function(response) {
      $this.removeAttr('disabled');
      $this.toggleClass('btn-success btn-danger');
      $this.text(response['interested_text']);
    })
    .fail(function(response) {
      $this.removeAttr('disabled');
    })
  });
});
