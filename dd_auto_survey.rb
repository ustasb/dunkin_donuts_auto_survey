# coding: utf-8

require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app)
end

module DunkinDonuts
  TELL_DUNKIN_URL = 'https://www.telldunkin.com'

  class AutoSurvey
    REQUEST_SUCCESS = true
    REQUEST_FAILED = false

    FUNNY_MESSAGE_MIN_PROGRESS_PERCENT = 20
    FUNNY_MESSAGE_CHANCE = 1.to_f / 5
    FUNNY_MESSAGES = [
      "Ugh, I hate filling out surveys...",
      "Help me...",
      "I miss being outside...",
      "This blows...",
      "This is depressing...",
    ]

    def initialize(survey_code, &progress_cb)
      @survey_code = survey_code.split('-')
      @progress_cb = progress_cb || -> (status) {}
    end

    def get_validation_code
      visit_welcome_page
      if enter_survey_code
        answer_questions
        code = extract_validation_code
        update_progress_status("Done! Your validation code is: #{code}")
        code
      end
    rescue Capybara::ElementNotFound
      update_progress_status("Oh no! The survey has changed! Tell Brian to fix me.")
    rescue
      update_progress_status("Oh no! Something unusual happened! Try again.")
    ensure
      session.driver.quit
      update_progress_status("___DONE___")
    end

    private

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

    def get_funny_message
      @funny_messages ||= FUNNY_MESSAGES.dup.shuffle
      rand() <= FUNNY_MESSAGE_CHANCE && @funny_messages.shift
    end

    def update_progress_status(status, funny_message = false)
      @progress_cb.call(
        funny_message ? get_funny_message || status : status
      )
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

      if session.has_content?('For verification purposes, please re-enter')
        update_progress_status("Dunkin' Donuts didn't like that survey code.")
        REQUEST_FAILED
      else
        REQUEST_SUCCESS
      end
    end

    def extract_validation_code
      session.find('#finishContent .ValCode').text[-5, 5]
    end

    def answer_questions
      while session.has_css?('#NextButton')
        progress_percentage = session.find('#ProgressPercentage').text.chop
        update_progress_status(
          "Answering questions - #{progress_percentage}% done",
          progress_percentage.to_i > FUNNY_MESSAGE_MIN_PROGRESS_PERCENT
        )

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
        REQUEST_SUCCESS
      else
        REQUEST_FAILED
      end
    end

    def random_click(elements)
      if elements.any?
        elements.sample.click
        REQUEST_SUCCESS
      else
        REQUEST_FAILED
      end
    end

    def answer_vertical_radio
      random_click session.all('.inputtyperblv .rbloption span')
    end

    def answer_checklist
      random_click session.all('.inputtypeopt .cataOption span')
    end

    def answer_tabled_questions
      table = session.all('table')
      if table.any?
        questions = table.first.all('.InputRowOdd, .InputRowEven')
        questions.each do |question|
          random_click question.all('.inputtyperbloption span')
        end
        REQUEST_SUCCESS
      else
        REQUEST_FAILED
      end
    end

    def answer_select_questions
      selects = session.all('.inputtypeddl select')
      if selects.any?
        selects.each { |select| select.select 'Prefer not to answer' }
        REQUEST_SUCCESS
      else
        REQUEST_FAILED
      end
    end
  end
end
