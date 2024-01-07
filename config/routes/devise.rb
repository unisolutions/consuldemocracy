devise_for :users, controllers: {
  # registrations: "users/registrations",
  sessions: "users/sessions",
  confirmations: "users/confirmations",
  omniauth_callbacks: "users/omniauth_callbacks"
}

devise_scope :user do
  patch "/user/confirmation", to: "users/confirmations#update", as: :update_user_confirmation
  get "/user/registrations/check_username", to: "users/registrations#check_username"
  get "users/sign_up/success", to: "users/registrations#success"
  get "users/registrations/delete_form", to: "users/registrations#delete_form"
  delete "users/registrations", to: "users/registrations#delete"
  get :finish_signup, to: "users/registrations#finish_signup"
  patch :do_finish_signup, to: "users/registrations#do_finish_signup"

  get '/viisp/authenticate', to: 'viisp#authenticate', as: :viisp_authenticate
  post '/viisp/callback', to: 'viisp#callback'
  get '/viisp/callback', to: 'viisp#callback'

  post '/users/handle', to: 'users/sessions#handle'

end

devise_for :organizations, class_name: "User",
                           controllers: {
                             registrations: "organizations/registrations",
                             sessions: "devise/sessions"
                           },
                           skip: [:omniauth_callbacks]

devise_scope :organization do
  get "organizations/sign_up/success", to: "organizations/registrations#success"
end
