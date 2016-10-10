// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('turbolinks:load', function() {
  $('.interested-domain, .check-domain').on('click', function(e) {
    var $this = $(this);
    $this.attr('disabled', 'disabled');

    if ($this.hasClass('interested-domain')) {
      var url = '/api/wanted_domains/interested';
      var disabledClass = 'disabled';
      var toggleClasses = 'btn-success btn-danger';
      var textField = 'interested_text';
    }
    else if ($this.hasClass('check-domain')) {
      var url = '/api/wanted_domains/check';
      var disabledClass = '';
      var toggleClasses = '';
      var textField = 'checked_text';
    }

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
      url: url
    })
    .done(function(response) {
      $this.removeAttr(disabledClass);
      $this.toggleClass(toggleClasses);
      $this.text(response[textField]);
    })
    .fail(function(response) {
      $this.removeAttr('disabled');
    })
  });
});
