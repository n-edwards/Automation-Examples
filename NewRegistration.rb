require 'watir-webdriver'
require 'rspec'

require_relative '../../../helpers/registration' # not included

describe 'Registration' do

  before(:each) do

    # registration codes redacted
    @t = Time.new
    @time = @t.month.to_s+@t.day.to_s+@t.year.to_s+@t.min.to_s+@t.sec.to_s
    @user_email = "homeroom_staging+"+@time+"@everfi.com"
    @user_name = "ned"+@time
    @HE_course_code = "" # Haven
    @HE_Alc_course_code = ""
    @K12_course_code = ""
    @K12_bundle_code = ""
    @HE_bundle_code = ""
    @K12_curriculum_code = ""
    @K12_CAN_course_code = ""
    @invalid_code = "bdaf987"
    @first_name = "Ned"
    @last_name = "Student"

    @browser = Watir::Browser.new :ff
    @browser.window.resize_to(1024, 920)
    @browser.goto "platform.everfi-staging.net/"
    end


  it 'tests invalid entries for Part 3 - Higher Ed' do

    @browser.button(:value,"Register").click
    @browser.link(:text, "Student/Learner").click
    sleep 1

    # testing invalid code instead of account code (SWW error page)
    @browser.text_field(:id, "reg_code").set @invalid_code
    @browser.button(:value, /Next/).click
    sleep 2
    expect(@browser.text).to include("invalid")
    sleep 2

    @browser.text_field(:id, "reg_code").set @HE_course_code
    @browser.button(:value, /Next/).click
    sleep 2

    @browser.button(:value, /Next/).click
    sleep 2
    expect(@browser.text).to include("Terms must be accepted")
    expect(@browser.text).to include("First Name can't be blank")
    expect(@browser.text).to include("Last Name can't be blank")
    expect(@browser.text).to include("Email is invalid")
    expect(@browser.text).to include("Password should contain")

    expect(@browser.text).to include("Student can't be blank") # student ID
    expect(@browser.text).to include("Select an answer above") # Tags

    expect(@browser.text).to include("Select an age range")
    expect(@browser.text).to include("Under 13")
    expect(@browser.text).to include("Between 13 and 18")
    expect(@browser.text).to include("18 or over")

    @browser.text_field(:id, "registration_signup_password").set "testing123"
    sleep 1
    expect(@browser.text).to include("Password Requirements")
    sleep 1

    #@browser.text_field(:id, "registration_signup_student_id").set "id123"

  end

  it 'finishes HE and actually registers' do

    Registration.register(@browser, @user_email, @user_name, @HE_course_code, false, @first_name, @last_name)

    #@browser.select_list(:id, /registration_signup_student_tag_curriculum/).select "Tag answer 1"

  end

  it 'tests invalid entries for Part 3 - K12' do

    @browser.button(:value,"Register").click
    @browser.link(:text, "Student/Learner").click
    sleep 1

    @browser.text_field(:id, "reg_code").set @K12_course_code
    @browser.button(:value, /Next/).click
    sleep 2

    @browser.text_field(:id, "registration_signup_email").set "nedateverfidotcom"
    @browser.button(:value, /Next/).click
    sleep 2
    expect(@browser.text).to include("Email is invalid")
    expect(@browser.text).to include("Terms must be accepted")
    expect(@browser.text).to include("Date Of Birth is required")
    expect(@browser.text).to include("First Name can't be blank")
    expect(@browser.text).to include("Last Name can't be blank")
    expect(@browser.text).to include("Username can't be blank")
    expect(@browser.text).to include("Password should contain")

    #expect(@browser.text_fields).not_to include

    # age stuff
    expect(@browser.text_field(:id, /registration_signup_email/).present?).to be true
    expect(@browser.text_field(:id, /registration_signup_last_name/).placeholder).to include("Last Name")
    @browser.select_list(:id, /date_month/).options.[](1).select
    @browser.select_list(:id, /date_day/).options.[](1).select
    @browser.select_list(:id, /date_year/).options.[](1).select
    sleep 2
    expect(@browser.text_field(:id, /registration_signup_email/).present?).to be false # no email for under 13
    expect(@browser.text_field(:id, /registration_signup_last_name/).placeholder).to include("Last Initial")
    expect(@browser.text_field(:id, /registration_signup_last_name/).placeholder).not_to include("Last Name")

    @browser.text_field(:id, "registration_signup_password").set "testing123"
    sleep 1
    expect(@browser.text).to include("Password Requirements")
    sleep 1

    # maybe set name for initial and try to test char limit/error

  end

  it 'finishes K12 Student, and actually registers' do
    sleep 3
    Registration.register(@browser, @user_email, @user_name, @K12_course_code, true, @first_name, @last_name)
    sleep 2
    expect(@browser.text).to include("Registration completed successfully.")

  end

  it 'tests Part 4 - K12 Teacher registration' do

    # invalid stuff
    @browser.button(:value,"Register").click
    @browser.link(:text, "Teacher").click
    sleep 1

    @browser.text_field(:id, "teacher_reg_code").set @invalid_code
    @browser.button(:value, /Next/).click
    sleep 2
    expect(@browser.text).to include("invalid")
    sleep 2

    @browser.text_field(:id, "teacher_reg_code").set @K12_curriculum_code
    @browser.button(:value, /Next/).click
    sleep 2

    @browser.button(:value, /Next/).click
    sleep 2
    expect(@browser.text).to include("Email is invalid")
    expect(@browser.text).to include("Password should contain")
    expect(@browser.text).to include("First Name can't be blank")
    expect(@browser.text).to include("Last Name can't be blank")
    expect(@browser.text).to include("Terms must be accepted")

    @browser.text_field(:id, "registration_signup_password").set "testing123"
    sleep 1
    expect(@browser.text).to include("Password Requirements")
    sleep 1
    @browser.text_field(:id, "registration_signup_password_confirmation").set "testing123"

    @browser.text_field(:id, "registration_signup_first_name").set @first_name
    @browser.text_field(:id, "registration_signup_first_name").set @last_name
    @browser.text_field(:id, "registration_signup_email").set @user_email

    @browser.checkbox(:id => "registration_signup_terms").set
    @browser.select_list(:id, /registration_signup_curriculum_id/).options.[](0).select
    @browser.link(:text, "?").click
    sleep 2
    expect(@browser.text).to include("Financial capability is an increasingly important skill")
    expect(@browser.link(:text, /Watch a Video Demo/).present?).to be true
    @browser.button(:text, /Close/).click
    sleep 1
    @browser.button(:value, /Next/).click

  end

  it 'tests Part 6 - K12 Bundle Registration' do
    Registration.register(@browser, @user_email, @user_name, @K12_bundle_code, false, @first_name, @last_name)

    expect(@browser.link(:href, "/dashboard/curriculums/12").present?).to be true #12 for Radius
    expect(@browser.link(:href, "/dashboard/curriculums/4").present?).to be true #4 for Vault

  end


  it 'tests Part 6 - HE Bundle Registration expectations' do

    @browser.button(:value,"Register").click
    @browser.link(:text, "Student/Learner").click
    sleep 1

    @browser.text_field(:id, "reg_code").set @HE_bundle_code
    @browser.button(:value, /Next/).click
    sleep 2

    expect(@browser.text_field(:id, /registration_signup_student_id/).present?).to be true
    expect(@browser.text_field(:id, /registration_signup_student_id/).placeholder).to include("Enter your student ID")
    @browser.select_list(:id, /registration_signup_student_tag_curriculum/).options.[](1).select

  end

  it 'registers with HE bundle' do

    Registration.register(@browser, @user_email, @user_name, @HE_bundle_code, false, @first_name, @last_name)

    expect(@browser.link(:href, "/dashboard/curriculums/8").present?).to be true #8 for Haven
    expect(@browser.link(:href, "/dashboard/curriculums/10").present?).to be true #10 for AlcoholEdu for College

  end

  it 'registers for Haven, adds a bundle code, then checks error for duplicate course' do

    Registration.register(@browser, @user_email, @user_name, @HE_Alc_course_code, false, @first_name, @last_name)
    sleep 2
    expect(@browser.link(:href, "/dashboard/curriculums/10").present?).to be true
    expect(@browser.link(:href, "/dashboard/curriculums/8").present?).to be false

    @browser.text_field(:id, "code").set @HE_bundle_code
    sleep 1
    @browser.button(:value, "Add").click
    sleep 3

    @browser.text_field(:id, /registration_signup_student_id/).set @user_name
    @browser.select_list(:id, /registration_signup_student_tag_curriculum/).options.[](1).select
    sleep 1
    @browser.button(:value, /Next/).click
    sleep 4

    expect(@browser.link(:href, "/dashboard/curriculums/8").present?).to be true

    @browser.text_field(:id, "code").set @HE_course_code
    sleep 1
    @browser.button(:value, "Add").click
    sleep 3
    expect(@browser.text).to include("You already are enrolled") # from Part 8

    @browser.text_field(:id, "code").set @invalid_code
    sleep 1
    @browser.button(:value, "Add").click
    sleep 3
    expect(@browser.text).to include("invalid") # from Part 8

  end

  it 'tests Part 7 - Canadian K12 reg expectations' do

    @browser.button(:value,"Register").click
    @browser.link(:text, "Student/Learner").click
    sleep 1

    @browser.text_field(:id, "reg_code").set @K12_CAN_course_code
    @browser.button(:value, /Next/).click
    sleep 2

    expect(@browser.text_field(:id, /registration_signup_last_name/).placeholder).to include("Last Initial")

  end

  it 'registers for CAN K12 and edits profile' do

    Registration.register(@browser, @user_email, @user_name, @K12_CAN_course_code, false, @first_name, @last_name) # doesn't seem any errors happen when trying to set last name to last initial field

    @browser.link(:class, "user-link dropdown-toggle").click
    sleep 1
    @browser.link(:title, /My Profile/).click
    sleep 3

    @browser.text_field(:id, "current_password").set "testing123"
    sleep 1
    @browser.text_field(:id, /registration_signup_password/).set "testing1234"
    sleep 1
    @browser.text_field(:id, /registration_signup_password_confirmation/).set "testing1234"
    sleep 1
    @browser.button(:name, "commit").click # Clicking value "Save" here is finding button on courses page for saving codes, generating error.
    sleep 3
    expect(@browser.text).to include("Your profile has been updated.")
  end

end
