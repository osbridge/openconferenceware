Given /^I am logged in as "([^\"]*)"$/ do |login|
  @user = User.find(Fixtures.identify(login))
  post browser_session_path, :login_as => @user.login
  session[:user].should == @user.id
end

Given /^I am not logged in$/ do
  @user = nil
  delete logout_path
  session[:user].should == nil
end
