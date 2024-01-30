class ClearTableName < ActiveRecord::Migration[6.1]
 def change
    User.delete_all
  end
end
