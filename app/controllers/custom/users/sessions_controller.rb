require 'viisp/auth'
require 'faraday'

class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token

  def new
    referrer = request.env["HTTP_REFERER"]
    setting = Setting.find_by(key: "back_url")
    if setting && referrer && referrer != "#{request.protocol}#{request.host_with_port}/users/sign_in" #For some reason, after viisp callback referrer gets set to users/sign_in
      setting.update(value: referrer)
    else
      if referrer != "#{request.protocol}#{request.host_with_port}/users/sign_in"
        Setting.create(key: "back_url", value: referrer)
      end
    end

    redirect_to viisp_authenticate_path
  end

  def create
    # redirect_to root_path and return
    super
  end

  def handle
  end

  def destroy
    @stored_location = stored_location_for(:user)
    super
  end

  private

  def after_sign_in_path_for(resource)
    if !verifying_via_email? && resource.show_welcome_screen?
      welcome_path
    else
      super
    end
  end

  def after_sign_out_path_for(resource)
    @stored_location.present? && !@stored_location.match("management") ? @stored_location : super
  end

  def verifying_via_email?
    return false if resource.blank?

    stored_path = session[stored_location_key_for(resource)] || ""
    stored_path[0..5] == "/email"
  end
end
