require 'capybara/poltergeist'

TELL_DUNKIN_URL = 'https://www.telldunkin.com'
#SURVEY_CODE = %w{ 07501 08475 1303 0845 }
#SURVEY_CODE = %w{ 58201 39117 0903 1447 }
SURVEY_CODE = %w{ 57601 39117 0903 1449 }

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app)
end

session = Capybara::Session.new(:poltergeist)

# first page
session.visit TELL_DUNKIN_URL
session.click_link 'click here'

# survey code entry
session.within('#surveyEntryForm') do
  session.fill_in 'CN1', with: SURVEY_CODE[0]
  session.fill_in 'CN2', with: SURVEY_CODE[1]
  session.fill_in 'CN3', with: SURVEY_CODE[2]
  session.fill_in 'CN4', with: SURVEY_CODE[3]
  session.click_button 'Start'
end

def answer(session)
  if session.has_content?("For data quality purposes, please select")
    table = session.find('table')
    quiz_number = table.find('.LeftColumn').text[-2]
    table.find(".Opt#{quiz_number} span").click
  else

    # Vertical radio
    options = session.all('.inputtyperblv .rbloption span')
    return options.sample.click if options.any?

    # Checklist
    options = session.all('.inputtypeopt .cataOption span')
    return options.sample.click if options.any?

    # Tables
    table = session.all('table')
    if table.any?
      questions = table.first.all('.InputRowOdd, .InputRowEven')
      questions.each do |question|
        question.all('.inputtyperbloption span').sample.click
      end
      return
    end

    # Select
    selects = session.all('.inputtypeddl select')
    if selects.any?
      selects.each do |select|
        select.select 'Prefer not to answer'
      end
      return
    end
  end
end

while session.has_css?('#NextButton')
  puts session.find('#ProgressPercentage').text
  puts session.text
  puts "==========="
  session.within('#surveyForm') do
    answer(session)
  end
  session.click_button 'Next'
end

puts session.find('#finishContent .ValCode').text
