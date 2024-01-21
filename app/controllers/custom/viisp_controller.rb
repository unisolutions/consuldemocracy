class ViispController < Devise::SessionsController
  skip_authorization_check
  skip_before_action :verify_authenticity_token

  def authenticate

    VIISP::Auth.configure do |c|
      c.pid = 'VSID000000000113'
      c.private_key = OpenSSL::PKey::RSA.new(File.read('./config/keys/testKey.pem'))
      c.postback_url = 'http://212.24.109.28:3000/viisp/callback'

      # optional
      c.providers = %w[auth.lt.identity.card auth.lt.bank]
      c.attributes = %w[lt-personal-code lt-company-code]
      c.user_information = %w[firstName lastName companyName email]

      # enable test mode
      # (in test mode there is no need to set pid and private_key)
      c.test = true # Rails.env.test? # Adjust this condition based on your environment
    end

    ticket = VIISP::Auth.ticket

    redirect_to "#{VIISP::Auth.portal_endpoint}?ticket=#{ticket}"
  end

  def callback
    back_url_setting = Setting.find_by(key: "back_url")

    ticket = params[:ticket]
    identity = VIISP::Auth.identity(ticket: ticket, include_source_data: true)

    personal_code = identity["attributes"]["lt-personal-code"]
    first_name = identity["user_information"]["firstName"]
    last_name = identity["user_information"]["lastName"]
    email = identity["user_information"]["email"]

    if email.blank?
      default_email = "noemail@krs.lt"
      email = default_email
    end

    user = User.find_by(document_number: personal_code)

    if user.nil?
      user = User.new(
        username: "#{first_name} #{last_name}",
        email: email,
        document_number: personal_code,
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
      if user.show_welcome_screen?
        welcome_path
      else
        if back_url_setting
          redirect_to back_url_setting.value
        else
          respond_with user, location: after_sign_in_path_for(user)
        end
      end
    else
      flash[:alert] = t('devise.failure.invalid', authentication_keys: 'login')
      redirect_to root_path
    end

  end
end
