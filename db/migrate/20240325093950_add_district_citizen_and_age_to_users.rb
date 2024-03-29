class AddDistrictCitizenAndAgeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :district_citizen, :boolean, default: false
    add_column :users, :age, :integer, limit: 3, default: 0
  end
end
