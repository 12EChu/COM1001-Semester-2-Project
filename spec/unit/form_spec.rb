require "rspec"
require "rack/test"

require_relative "../spec_helper"

RSpec.describe "Form Test" do
  include Rack::Test::Methods

  describe "POST /post-login" do
    context "submission of mentee login details" do
      it "will redirect to the mentee home page" do
        user = User.new(first_name: "Bonny", surname: "Simmons", email: "BSimmons@gmail.ac.uk", password: "Password1",
                        privilege: Privilege.new.from_name("Mentee"))
        user.save_changes
        post "/post-login", "email" => "BSimmons@gmail.ac.uk", "password" => "Password1"
        expect(last_response.location).to include("/mentee")
        DB.from("users").delete
      end
    end
    
    context "submission of mentor login details" do
      it "will redirect to the mentor home page" do
        user = User.new(first_name: "TestPerson", surname: "Two", email: "Test2@gmail.ac.uk", password: "Password1",
                        privilege: Privilege.new.from_name("Mentor"))
        user.save_changes
        post "/post-login", "email" => "Test2@gmail.ac.uk", "password" => "Password1"
        expect(last_response.location).to include("/mentor")
        DB.from("users").delete
      end
    end
    
    context "submission of admin login details" do
      it "will redirect to the admin home page" do
        user = User.new(first_name: "TestPerson", surname: "Three", email: "Test3@gmail.ac.uk", password: "Password1",
                        privilege: Privilege.new.from_name("Admin"))
        user.save_changes
        post "/post-login", "email" => "Test3@gmail.ac.uk", "password" => "Password1"
        expect(last_response.location).to include("/admin")
        DB.from("users").delete
      end
    end
    
    context "submission of account details that does not exist in database" do
      it "will redirect to the login page which indicates error" do
        post "/post-login", "email" => "invalidEmail@gmail.ac.uk", "password" => "InvalidPassword"
        expect(last_response.location).to include("/login?error=1")
      end
    end
    
    context "Submission of suspended account" do
      it "will redirect to the login page indicating that account is suspended" do
        user = User.new(first_name: "TestPerson", surname: "Four", email: "Test4@gmail.ac.uk", password: "Password1",
                        privilege: Privilege.new.from_name("Admin"), suspend: "1")
        user.save_changes
        post "/post-login", "email" => "Test4@gmail.ac.uk", "password" => "Password1"
        expect(last_response.location).to include("/login?error=2")
        DB.from("users").delete
      end
    end
  end
  
  describe "POST /post-register" do
    context "creating a mentee account" do
      it "will redirect to the /mentee-register page" do
        post "/post-register", "first_name" => "TestPerson", "surname" => "One", "email" => "Test1@gmail.ac.uk", "password" => "Password1","confirmpassword" => "Password1","privilege" => "Mentee"
        expect(last_response.location).to include("/mentee-register")
        DB.from("users").delete
      end
    end
    
    context "creating a mentor account" do
      it "will redirect to the /mentor-register page" do
        post "/post-register", "first_name" => "TestPerson", "surname" => "Two", "email" => "Test2@gmail.ac.uk", "password" => "Password1","confirmpassword" => "Password1","privilege" => "Mentor"
        expect(last_response.location).to include("/mentor-register")
        DB.from("users").delete
      end
    end
    
    context "entering different password and confirm password" do
      it "will display message 'The two password entries must be correct.'" do
        post "/post-register", "first_name" => "TestPerson", "surname" => "Two", "email" => "Test2@gmail.ac.uk", "password" => "Password1","confirmpassword" => "differentPassword","privilege" => "Mentor"
        expect(last_response.location).to include("/register?error=1")
        DB.from("users").delete
      end
    end
    
    context "mentee entering email that is not university email" do
      it "will display message 'Mentee email must be a university email." do
        post "/post-register", "first_name" => "TestPerson", "surname" => "Two", "email" => "Test2@gmail.com", "password" => "Password1","confirmpassword" => "differentPassword","privilege" => "Mentee"
        expect(last_response.location).to include("/register?error=2")
        DB.from("users").delete
      end
    end
  end
  
  describe "POST /post-profile" do
    context "changing mentee profile information" do
      it "after changes made it will redirect to /dashboard" do
        desc = Description.new(description: "I study maths")
        desc.save_changes
        user = User.new(first_name: "Bonny", surname: "Simmons", email: "BSimmons@gmail.ac.uk", password: "Password1",
                        privilege: Privilege.new.from_name("Mentee"))
        
        user.description = desc.id
        user.save_changes
        rack_mock_session.cookie_jar['id'] = user.id
        post "/post-profile", "university" => "The University of Sheffield", "degree" => "Mathematics", "telephone" => "07515448511", "password" => ""
        expect(last_response.location).to include("/dashboard")
        DB.from("users").delete
        DB.from("descriptions").delete
      end
    end
    
    context "changing password" do
      it "will save changes, send a notification email and redirect to /dashboard" do
        desc = Description.new(description: "I study maths")
        desc.save_changes
        user = User.new(first_name: "Bonny", surname: "Simmons", email: "BSimmons@gmail.ac.uk", password: "Password1",
                        privilege: Privilege.new.from_name("Mentee"))
        
        user.description = desc.id
        user.save_changes
        rack_mock_session.cookie_jar['id'] = user.id
        post "/post-profile", "university" => "The University of Sheffield", "degree" => "Mathematics", "telephone" => "07515448511", "password" => "Password1","newpassword" => "Password2", "newconfirmpassword" => "Password2"
        expect(last_response.location).to include("/dashboard")
        DB.from("users").delete
        DB.from("descriptions").delete
      end
    end
    
    context "made change to only one password field" do
      it "redirect and print an error message on screen" do
        desc = Description.new(description: "I study maths")
        desc.save_changes
        user = User.new(first_name: "Bonny", surname: "Simmons", email: "BSimmons@gmail.ac.uk", password: "Password1",
                        privilege: Privilege.new.from_name("Mentee"))
        
        user.description = desc.id
        user.save_changes
        rack_mock_session.cookie_jar['id'] = user.id
        post "/post-profile", "university" => "The University of Sheffield", "degree" => "Mathematics", "telephone" => "07515448511", "password" => "Password1","newpassword" => "", "newconfirmpassword" => "Password2"
        expect(last_response.location).to include("/profile?error3=1")
        DB.from("users").delete
        DB.from("descriptions").delete
      end
    end
  end
  
#   describe "POST /post-make-report" do
#     context "identifier and description of what happened is posted in form" do
#       it "will make new report with saved information then redirect to /dashboard" do
#         desc = Description.new
#         desc.load("description"=>"something")
#         desc.save_changes
#         user = User.new
#         user.save_changes
# #         desc.save_changes
#         #user.description = desc.id
#         rack_mock_session.cookie_jar['id'] = user.id
#         post "/post-make-report", "identifier" => "Name", "description"=> "something"
#         expect(last_response.location).to include("/dashboard")
#         DB.from("users").delete
#         DB.from("descriptions").delete
#       end
#     end
#   end
end
