class DeleteUsers < ActiveRecord::Migration[6.1]
  def change
      User.find_by(email: "simonassnio@gmail.com").delete
      User.find_by(email: "simonas@unisolutions.eu").delete
  end
end
