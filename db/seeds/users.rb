User.create!(username: "Anonimas", email: "X@X.X", password: Rails.configuration.anonymous_credentials,
             password_confirmation: Rails.configuration.anonymous_credentials, document_number: Rails.configuration.anonymous_credentials, confirmed_at: Time.current,
             terms_of_service: "1")
