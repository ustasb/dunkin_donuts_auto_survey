(function () {

var $window = $(window),
    $contentWrapper = $('#content-wrapper'),
    $button = $('button'),
    $inputs = $('input'),
    $status = $('#submit-status'),
    eventSource = null;

function validateSurveyCode(surveyCode) {
  return /^\w{5}-\w{5}-\w{4}-\w{4}$/.test(surveyCode);
}

function getSurveyCode() {
  return $inputs.map(function () {
    return $(this).val();
  }).toArray().join('-');
}

function disableInput() {
  $button.prop('disabled', true);
  $inputs.prop('disabled', true);
}

function enableInput() {
  $button.prop('disabled', false);
  $inputs.prop('disabled', false);
}

function showStatus(status) {
  $status.show().text(status);
}

function hideStatus(timeout) {
  var timeout = timeout || 0;

  setTimeout(function () {
    $status.hide();
  }, timeout);
}

function onSubmit() {
  var surveyCode = getSurveyCode();

  if (true || validateSurveyCode(surveyCode)) {
    disableInput();

    getValidationCode('5761-391-093-1449', function () {
      enableInput();
    });
  } else {
    showStatus('Invalid Survey Code!');
    hideStatus(3500);
  }
}

function inputKeyUp() {
  var $input = $(this);

  if ($input.val().length >= $input.attr('maxlength')) {
    var nextTabIndex = parseInt($input.attr('tabIndex'), 10) + 1;
    $('*[tabIndex="' + nextTabIndex + '"]').focus();
  }
}

function centerContent() {
  var marginTop = ($window.height() - $contentWrapper.height()) / 2;
  var offset = 40;

  marginTop -= offset;
  if (marginTop < 0) { marginTop = 0; }

  $contentWrapper.css('margin-top', marginTop);
}

function getValidationCode(surveyCode, onDone) {
  eventSource && eventSource.close();
  eventSource = new EventSource('/validationcode/' + surveyCode);

  eventSource.onmessage = function (e) {
    var status = e.data;
    showStatus(status);

    if (/Done!|Exiting/.test(status)) {
      eventSource.close();
      eventSource = null;
      onDone();
    }
  };

  eventSource.onerror = function (e) {
    showStatus("An error occured! Try again some other time...");
    eventSource.close();
    eventSource = null;
    onDone();
  };
}

function init() {
  centerContent();
  $button.click(onSubmit);
  $inputs.keyup(inputKeyUp);
  $window.resize(centerContent);
}

init();

}());
