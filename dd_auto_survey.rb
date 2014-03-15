require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app)
end

module DunkinDonuts
  TELL_DUNKIN_URL = 'https://www.telldunkin.com'

  class AutoSurvey

    def initialize(survey_code, &progress_cb)
      @survey_code = survey_code.split('-')
      @progress_cb = progress_cb
    end

    def get_validation_code
      visit_welcome_page
      enter_survey_code
      answer_questions
      code = extract_validation_code
      update_progress_status("Done! Your validation code is: #{code}")
      code
    end

    private

    def update_progress_status(status)
      @progress_cb.call(status) if @progress_cb
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

    def visit_welcome_page
      update_progress_status('Visiting the welcome page...')

      session.visit TELL_DUNKIN_URL
      session.click_link 'click here'
    end

    def enter_survey_code
      update_progress_status('Entering your survey code...')

      session.within('#surveyEntryForm') do
        session.fill_in 'CN1', with: @survey_code[0]
        session.fill_in 'CN2', with: @survey_code[1]
        session.fill_in 'CN3', with: @survey_code[2]
        session.fill_in 'CN4', with: @survey_code[3]
        session.click_button 'Start'
      end
    end

    def extract_validation_code
      session.find('#finishContent .ValCode').text[-5, 5]
    end

    def answer_questions(&progress_cb)
      while session.has_css?('#NextButton')
        progress_percentage = session.find('#ProgressPercentage').text
        update_progress_status("Answering questions - #{progress_percentage} done")

        session.within('#surveyForm') do
          answer_quiz_question ||
          answer_vertical_radio ||
          answer_checklist ||
          answer_tabled_questions ||
          answer_select_questions
        end

        session.click_button 'Next'
      end
    end

    def answer_quiz_question
      if session.has_content?("For data quality purposes, please select")
        table = session.find('table')
        quiz_number = table.find('.LeftColumn').text[-2]
        table.find(".Opt#{quiz_number} span").click
        true
      else
        false
      end
    end

    def answer_vertical_radio
      options = session.all('.inputtyperblv .rbloption span')
      sample = options.sample
      sample.click if sample
      !!sample
    end

    def answer_checklist
      options = session.all('.inputtypeopt .cataOption span')
      sample = options.sample
      sample.click if sample
      !!sample
    end

    def answer_tabled_questions
      table = session.all('table')
      if table.any?
        questions = table.first.all('.InputRowOdd, .InputRowEven')
        questions.each do |question|
          question.all('.inputtyperbloption span').sample.click
        end
        true
      else
        false
      end
    end

    def answer_select_questions
      selects = session.all('.inputtypeddl select')
      if selects.any?
        selects.each { |select| select.select 'Prefer not to answer' }
        true
      else
        false
      end
    end

  end
end

#s1 = '07501-08475-1303-0845'
#s2 = '58201-39117-0903-1447'
#s3 = '57601-39117-0903-1449'
