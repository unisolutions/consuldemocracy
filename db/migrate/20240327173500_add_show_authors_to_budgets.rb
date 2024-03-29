class AddShowAuthorsToBudgets < ActiveRecord::Migration[6.1]
  def change
    add_column :budgets, :show_authors, :boolean, default: false
  end
end
