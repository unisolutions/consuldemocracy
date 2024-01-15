class AddPreliminaryPriceToBudgetInvestmentTranslations < ActiveRecord::Migration[6.1]
  def change
    add_column :budget_investment_translations, :preliminary_price, :integer
  end
end
