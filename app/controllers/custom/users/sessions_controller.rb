require 'viisp/auth'
require 'faraday'

class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token

  def new
    if request.referrer != nil && !request.referrer.include?("/users/sign_in")
      cookies[:back_url] = request.referrer
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
    super
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  def verifying_via_email?
    return false if resource.blank?

    stored_path = session[stored_location_key_for(resource)] || ""
    stored_path[0..5] == "/email"
  end
end
