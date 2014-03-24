(function () {

var $window = $(window),
    $contentWrapper = $('#content-wrapper'),
    $submitButton = $('button'),
    $inputs = $('input'),
    $status = $('#submit-status'),
    $surveysCompleted = $('#surveys-completed span'),
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
  $submitButton.prop('disabled', true);
  $inputs.prop('disabled', true);
}

function enableInput() {
  $submitButton.prop('disabled', false);
  $inputs.prop('disabled', false);
}

function showStatus(status) {
  $status.show().text(status);
}

function hideStatus(timeout) {
  setTimeout(function () {
    $status.hide();
  }, timeout || 0);
}

function onSubmit() {
  var surveyCode = getSurveyCode();

  if (validateSurveyCode(surveyCode)) {
    disableInput();

    getValidationCode(surveyCode, function () {
      enableInput();
    });
  } else {
    showStatus('Invalid survey code!');
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

function bumpSurveysCompletedCount() {
  var count = $surveysCompleted.text().match(/\d*$/)[0];
  $surveysCompleted.text( (parseInt(count, 10) || 0) + 1 );
}

function getValidationCode(surveyCode, onDone) {
  eventSource && eventSource.close();
  eventSource = new EventSource('/validation_code/' + surveyCode);

  eventSource.onmessage = function (e) {
    var status = e.data;

    if (/___DONE___/.test(status)) {
      eventSource.close();
      eventSource = null;
      onDone();
    } else {
      if (/Your validation code is/.test(status)) {
        bumpSurveysCompletedCount();
      }
      showStatus(status);
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
  $submitButton.click(onSubmit);
  $inputs.keyup(inputKeyUp);
  $window.resize(centerContent);

  $.get('/surveys_completed', function (count) {
    $surveysCompleted.text(count);
  });
}

init();

}());
