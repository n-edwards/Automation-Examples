require 'watir-webdriver'
require 'rspec'

# helpers not included
require_relative '../../../helpers/registration'
require_relative '../../../helpers/complete_survey_haven'

describe 'Haven Smoke Test' do

  before:all do
    @t = Time.new
    @time = @t.month.to_s+@t.day.to_s+@t.year.to_s+@t.min.to_s+@t.sec.to_s
    @user_email = "ned+"+@time+"@everfi.com"
    @user_name = "ned"+@time
    @account_email = ""
    @course_code = "" # redacted
    @first_name = "Ned"
    @last_name = "Student"

    @browser = Watir::Browser.new :ff
    @browser.window.resize_to(1024, 920)
    @browser.goto "platform.everfi.net/"
  end

  it "Was able to register sucessfuly" do
    Registration.register(@browser, @user_email, @user_name, @course_code, false, @first_name, @last_name)
  end

  it 'Completes Haven intro' do
    if @browser.a(:text => "Get Started").present?
      @browser.a(:text => "Get Started").click
    end

    sleep 5
    @browser.iframe(:class => /iframe_div course-div/).div(:id => /menuItem-m01/).link.when_present.click
    sleep 5
    @browser.iframe(:class => /iframe_div course-div/).div(:class => "hexBackground").link.click
    sleep 15 # next button disabled when voiceover starts
    @browser.iframe(:class => /iframe_div course-div/).a(:id => /arrowRight/).when_present.click
    sleep 15
    @browser.iframe(:class => /iframe_div course-div/).a(:id => /arrowRight/).when_present.click
  end

  it "Was able to complete the Survey" do
    @frame = @browser.iframe(:class => /iframe_div course-div/)
    @frame.button(:text => /Continue/).when_present.click
    while @frame.section(:class => /section/).exists?
      Complete_survey_Haven.complete_survey_haven(@frame)
      sleep 2
      Complete_survey_Haven.continue(@frame)
      sleep 2
      @frame.button(:text => "Submit Answers and Continue").click if @frame.button(:text => "Submit Answers and Continue").present?
      puts "Completed a survey page"
    end
  end

  it 'Completes pre-quiz' do
    @frame = @browser.iframe(:class => /iframe_div course-div/)
    @frame.a(:text => /Get Started/).click

    # No class types for fieldsets in the quiz, so not using the survey completer.
    @frame.div(:class => /questions/).divs(:class => /answer-block/).each do |answer_column|
      if answer_column.present?
          answers = answer_column.labels
          random_answer = rand(0..(answers.length - 1))
          answers.[](random_answer).click
          sleep 0.5
      end
    end
    Complete_survey_Haven.continue(@frame)
      sleep 1

    @frame.div(:class => /questions/).divs(:class => /answer-block/).each do |answer_column|
      if answer_column.present?
        answers = answer_column.labels
        random_answer = rand(0..(answers.length - 1))
        answers.[](random_answer).click
        sleep 0.5
      end
    end
    @frame.button(:text => /Submit Answers/).when_present.click
    end


  it 'Completes Haven intro part 2' do
    sleep 15
    @browser.iframe(:class => /iframe_div course-div/).a(:id => /arrowRight/).click
    sleep 15
    @browser.iframe(:class => /iframe_div course-div/).a(:id => /arrowRight/).click
    sleep 80 # 1:16 video
    @browser.iframe(:class => /iframe_div course-div/).a(:id => /arrowRight/).click
  end

  it 'Completes Haven CONNECTIONS' do
    sleep 3
    @browser.iframe(:class => /iframe_div course-div/).div(:id => "menuItem-m02").link.click
    sleep 3

    @browser.iframe(:class => /iframe_div course-div/).div(:id => "menuItem-a01").link.click
    sleep 6
    @browser.iframe(:class => /iframe_div course-div/).a(:id => /arrowRight/).click
    sleep 3

    # could choose random values here
    val1 = @browser.iframe(:class => /iframe_div course-div/).div(:text => "Ambition")
    slot1 = @browser.iframe(:class => /iframe_div course-div/).div(:id => "dropSlot1")
    val1.drag_and_drop_on slot1 # may only work in Firefox
    sleep 1

    val2 = @browser.iframe(:class => /iframe_div course-div/).div(:text => "Courage")
    slot2 = @browser.iframe(:class => /iframe_div course-div/).div(:id => "dropSlot2")
    val2.drag_and_drop_on slot2
    sleep 1

    val3 = @browser.iframe(:class => /iframe_div course-div/).div(:text => "Independence")
    slot3 = @browser.iframe(:class => /iframe_div course-div/).div(:id => "dropSlot3")
    val3.drag_and_drop_on slot3
    sleep 1

    val4 = @browser.iframe(:class => /iframe_div course-div/).div(:text => "Humor")
    slot4 = @browser.iframe(:class => /iframe_div course-div/).div(:id => "dropSlot4")
    val4.drag_and_drop_on slot4
    sleep 1

    val5 = @browser.iframe(:class => /iframe_div course-div/).div(:text => "Listening")
    slot5 = @browser.iframe(:class => /iframe_div course-div/).div(:id => "dropSlot5")
    val5.drag_and_drop_on slot5
    sleep 2

    @browser.iframe(:class => /iframe_div course-div/).div(:id => /submitWrapper/).link.click
    sleep 2

    @browser.iframe(:class => /iframe_div course-div/).a(:id => /arrowRight/).click
    sleep 6

    @browser.iframe(:class => /iframe_div course-div/).a(:id => /arrowRight/).click
  end
end
