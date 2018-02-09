require 'spec_helper' # Capybara

describe 'Unified Pages' do

  describe 'Platform' do

    it 'should check platform page' do

      visit '/'
      puts "Looking for platform page. Current URL is #{current_url}"
      result = expect(page).to be_accessible.skipping :'color-contrast'
      message 'Platform page is accessible', result

      # Footer
      expect(page).to have_css('a[href="http://support.everfi.com"]')
      expect(page).to have_css('a[href="http://www.everfi.com/"]')
      expect(page).to have_css('a[href="http://www.everfi.com/legal/terms-of-service"]')
      expect(page).to have_css('a[href="http://www.everfi.com/legal/privacy"]')

      # Header
      expect(page).to have_css('a[href="http://support.everfi.com/"]')
      expect(page).to have_css('a[href="http://everfi.com/contact-us/"]')
      result = expect(page).to have_css('a[href="http://everfi.com/"]')
      message 'EverFi links found on platform page', result

    end
  end

  describe 'Dashboard' do

    let(:bad_code) { FIXTURES[:reg_code][:invalid] }
    let(:k12_code) { FIXTURES[:reg_code][:k12] }
    let(:he_code) { FIXTURES[:reg_code][:he] }

    before(:each) do
      signup_with_reg_code(k12_code[:class_code])
      fill_in_registration_form(age: '12', curriculum_id: k12_code[:curriculum_id])
    end

    it 'checks help modal' do

      click_user_dropdown
      find('a[title^="Help"]').click
      expect(page).to be_accessible.within('div[class="helpModal"]')
      within('div[id="helpModal"]') do
        expect(page).to have_css('a[href="http://support.everfi.com/"]')
        result = expect(page).to have_text('You are running')
        message 'Help modal appears with info, and was found to be accessible', result
      end

    end

    it 'tries to add an invalid code' do

      add_course(bad_code)
      result = expect(page).to have_text("The code entered #{bad_code} is invalid.")
      message 'Cannot add course with bad code', result

    end

    it 'adds an HE course' do

      add_course(he_code[:class_code])
      fill_in_registration_form(age: '13', curriculum_id: he_code[:curriculum_id])
      result = find("div[aria-labelledby='#{he_code[:curriculum_name].camelize}']").visible?
      message 'Able to add HE course as K12 student', result

    end

    it 'tries to add same K12 cohort' do

      add_course(k12_code[:class_code])

      time = Time.now.strftime('%M%d%Y%S')
      email = "foo#{time}@bar.com"

      fill_in_registration_form(age: '12', curriculum_id: k12_code[:curriculum_id], options: email_known(email))
      enrollments = all("div[aria-labelledby='#{k12_code[:curriculum_name].camelize}']")
      result = expect(enrollments.size == 1)
      message 'Adding same cohort does not generate additional enrollment on student dashboard', result

      click_user_dropdown
      find('a[title^="My Profile"]').click
      result = expect(page).to have_text(email)
      message 'Changing user info when adding a course updates the user profile', result

    end

  end

  describe 'Past Courses' do

    let(:student) { FIXTURES[:k12][:past_student] }
    let(:enrollment) { student[:finlit_enroll] }

    before(:each) do
      sign_in_and_visit(student, '/dashboard/past_courses')
    end

    it 'checks for past course' do

      result = expect(page).to have_css("a[href='/dashboard/redirect_to_curriculum?enrollment_id=#{enrollment}']")
      message 'Courses from old implementation period appear in Past Courses tab', result

    end

  end

  describe 'Gatekeeper' do

    let(:userpre) { FIXTURES[:he][:gate_student] }
    let(:enrollment) { userpre[:alc_enroll] }
    let(:useradd) { FIXTURES[:he][:student] }
    let(:he_code) { FIXTURES[:reg_code][:he_gate][:class_code] }

    it 'checks ID and tag for student created before customizations' do

      sign_in(userpre)
      find("a[href='/dashboard/redirect_to_curriculum?enrollment_id=#{enrollment}']").click
      expect(page).to have_css('#registration_signup_student_tag_curriculum_id_10')
      result = expect(page).to have_css('#registration_signup_student_id')
      expect(page).to be_accessible.skipping :'color-contrast', :'aria-valid-attr-value', :'duplicate-id', :'label'
      message 'Reg customization gatekeeper appears for current student', result
    end

    it 'checks ID and tag for student adding curriculum with customizations' do

      sign_in(useradd)
      add_course(he_code)
      expect(page).to have_css('#registration_signup_student_tag_curriculum_id_10')
      expect(page).to have_css('#registration_signup_age_status')
      result = expect(page).to have_css('#registration_signup_student_id')
      expect(page).to be_accessible.skipping :'color-contrast', :'aria-valid-attr-value', :'duplicate-id', :'label'
      message 'Reg customization gatekeeper appears when adding course', result

    end

  end
end
