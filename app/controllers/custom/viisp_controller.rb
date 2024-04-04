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

    access_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovLzE5Mi4xNjguMjAxLjkwIiwiaWF0IjoxNzEwMzk3Nzg3LCJuYmYiOjE3MTAzOTc3ODcsImV4cCI6MTcxNTU4MTc4NywiZGF0YSI6eyJ1c2VyIjp7ImlkIjoiNTQifX19.lXW1G09PaENt4MC87f5Wm_mBHHsPL1r_v3CMwLYuohM"

    ticket = params[:ticket]
    identity = VIISP::Auth.identity(ticket: ticket, include_source_data: true)
    back_url = identity["custom_data"]
    personal_code = identity["attributes"]["lt-personal-code"]
    first_name = identity["user_information"]["firstName"]
    last_name = identity["user_information"]["lastName"]
    email = identity["user_information"]["email"]

    encrypted_personal_code = encrypt_string(personal_code)

    access_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovLzE5Mi4xNjguMjAxLjkwIiwiaWF0IjoxNzEwMzk3Nzg3LCJuYmYiOjE3MTAzOTc3ODcsImV4cCI6MTcxNTU4MTc4NywiZGF0YSI6eyJ1c2VyIjp7ImlkIjoiNTQifX19.lXW1G09PaENt4MC87f5Wm_mBHHsPL1r_v3CMwLYuohM"
    # access_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovLzE5Mi4xNjguMjAxLjkwIiwiaWF0IjoxNzA4NDE0Nzc1LCJuYmYiOjE3MDg0MTQ3NzUsImV4cCI6MTczODIzOTM4NCwiZGF0YSI6eyJ1c2VyIjp7ImlkIjoiNTQifX19.oKOPvlNSshn1_D4VjJFyOFn7UbyZOqxuBhfiksHgcaE"
    age = calculate_age_from_personal_code(personal_code)
    is_citizen = check_personal_code(personal_code, access_token)

    if email.blank?
      default_email = "#{encrypted_personal_code}@krs.lt"
      email = default_email
    end

    user = User.find_by(document_number: encrypted_personal_code)

    if user.nil?
      user = User.new(
        username: "#{first_name} #{last_name}",
        email: email,
        document_number: encrypted_personal_code,
        password: Devise.friendly_token[0, 20],
        terms_of_service: "1",
        age: age,
        district_citizen: is_citizen,
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

    user.update(username: "#{first_name} #{last_name}", district_citizen: is_citizen, age: age)

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

  def calculate_age_from_personal_code(personal_code)
    begin
      # Extracting the birth year, month, and day from the personal code
      birth_year_prefix = personal_code[0].to_i
      return 0 unless (1..6).include?(birth_year_prefix)

      birth_year = case birth_year_prefix
                   when 1, 2
                     1800 + personal_code[1, 2].to_i
                   when 3, 4
                     1900 + personal_code[1, 2].to_i
                   when 5, 6
                     2000 + personal_code[1, 2].to_i
                   end

      month = personal_code[3, 2].to_i
      day = personal_code[5, 2].to_i

      # Parsing the birthdate
      birthdate = Date.new(birth_year, month, day)

      # Calculating the age based on the birthdate and the current date
      current_date = Date.today
      age = current_date.year - birthdate.year
      age -= 1 if current_date.month < birthdate.month || (current_date.month == birthdate.month && current_date.day < birthdate.day)
      age >= 0 ? age : 0
    rescue ArgumentError => e
      puts "Error: #{e.message}"
      0
    end
  end

  def check_personal_code(personal_code, access_token)
    conn = Faraday.new(url: Rails.configuration.krs_endpoint) do |faraday|
      faraday.request :url_encoded
      faraday.headers['Authorization'] = "Bearer #{access_token}" if access_token
      faraday.adapter Faraday.default_adapter
    end

    response = conn.get("/wp-json/krsapi/v1/tikrinti/?asmensKodas=#{personal_code}")

    case response.body
    when "1"
      true
    when "0"
      false
    else
      puts "Unexpected response: #{response.body}"
      false
    end
  rescue Faraday::ConnectionFailed => e
    puts "Error connecting to the server: #{e}"
    false
  rescue Faraday::TimeoutError => e
    puts "Timeout error: #{e}"
    false
  end

end


