require 'bcrypt'

class ViispController < Devise::SessionsController
  skip_authorization_check
  skip_before_action :verify_authenticity_token

  def authenticate
    VIISP::Auth.configure do |c|
      c.pid = Rails.configuration.viisp_pid
      c.private_key = OpenSSL::PKey::RSA.new(File.read(Rails.configuration.viisp_key_route))
      c.postback_url = Rails.configuration.base_url + '/viisp/callback' # Rails.configuration.base_url

      # optional
      c.providers = %w[auth.lt.identity.card auth.lt.bank auth.signatureProvider]
      c.attributes = %w[lt-personal-code lt-company-code]
      c.user_information = %w[firstName lastName companyName email]

      # enable test mode
      # (in test mode there is no need to set pid and private_key)
      c.test = Rails.configuration.viisp_test # Rails.env.test? # Adjust this condition based on your environment
    end

    ticket = VIISP::Auth.ticket(
      custom_data: cookies[:back_url]
    )

    redirect_to "#{VIISP::Auth.portal_endpoint}?ticket=#{ticket}"
  end

  def callback
    ticket = params[:ticket]
    identity = VIISP::Auth.identity(ticket: ticket, include_source_data: true)
    back_url = identity["custom_data"]
    personal_code = identity["attributes"]["lt-personal-code"]
    first_name = identity["user_information"]["firstName"]
    last_name = identity["user_information"]["lastName"]
    email = identity["user_information"]["email"]

    if email.blank?
      default_email = "noemail@krs.lt"
      email = default_email
    end

    encrypted_personal_code = encrypt_string(personal_code)

    user = User.find_by(document_number: encrypted_personal_code)

    if user.nil?
      user = User.new(
        username: "#{first_name} #{last_name}",
        email: email,
        document_number: encrypted_personal_code,
        password: Devise.friendly_token[0, 20],
        terms_of_service: "1",
        confirmed_at: Time.current,
        verified_at: Time.current
      )

      # Save the new user
      if user.save
        flash[:notice] = t('devise.registrations.signed_up')
      else
        flash[:alert] = "Prisijungti nepavyko"
        redirect_to root_path and return
      end
    end

    # Authenticate the user
    if user
      sign_in(resource_name, user)
      yield user if block_given?
      # respond_with user, location: after_sign_in_path_for(user)
      redirect_to back_url || root_path
    else
      flash[:alert] = t('devise.failure.invalid', authentication_keys: 'login')
      redirect_to root_path
    end
  end

  def encrypt_string(input)
    sha256_hash = Digest::SHA256.hexdigest(input)
    truncated_hash = sha256_hash[0, 14]
    return truncated_hash.upcase
  end

end


