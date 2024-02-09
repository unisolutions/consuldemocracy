resource :account, controller: "account", only: [:show, :update] do
  get :erase, on: :collection
end

resource :subscriptions, only: [:edit, :update]
