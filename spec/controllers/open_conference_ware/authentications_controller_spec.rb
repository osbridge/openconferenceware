require 'spec_helper'

describe OpenConferenceWare::AuthenticationsController do
  routes { OpenConferenceWare::Engine.routes }

  describe "GET sign_in" do
    before { get :sign_in }

    it "renders the sign_in template" do
      expect(response).to render_template("sign_in")
    end
  end

  describe "GET create" do
    context "with no auth hash" do
      before { get :create }

      it "redirects to the sign in page" do
        expect(response).to redirect_to(sign_in_path)
      end
    end

    context "with an auth hash" do
      context "matching an existing User's Authentication" do
        let(:existing_user)  { create(:user) }
        let(:authentication) { create(:authentication,
                                      provider: 'existing',
                                      user: existing_user) }

        before do
          OmniAuth.config.add_mock(:existing, {uid: authentication.uid})
          request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:existing]
        end

        shared_examples_for "signs the user in" do
          it "signs the user in" do
            expect(controller.current_user).to eq existing_user
          end
        end

        context "when not already signed in" do
          before { get :create }
          include_examples "signs the user in"
        end

        context "when already signed in" do
          before { login_as(create(:user)) }
          before { get :create }
          include_examples "signs the user in"
        end
      end

      describe "containing an unknown UID" do
        describe "when already signed in" do
          let(:logged_in_user) { create(:user) }
          let(:uid)            { "logged-in:#{Time.now.to_i}" }

          before do
            login_as(logged_in_user)
            OmniAuth.config.add_mock(:logged_in, {uid: uid})
            request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:logged_in]

            get :create
          end

          it "associates the new Authentication with the signed-in user" do
            expect(logged_in_user.authentications.map(&:uid)).to include(uid)
          end
        end

        describe "when not signed in" do
          let(:uid) { "new-user:#{Time.now.to_i}" }
          before do
            OmniAuth.config.add_mock(:new_user, {uid: uid})
            request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:new_user]

            get :create
          end

          it "signs in as a new user" do
            expect(controller.current_user.authentications.first.uid).to eq uid
          end
        end
      end
    end
  end
end
