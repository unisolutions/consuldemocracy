class AddBallotWinnerToBudgetInvestments < ActiveRecord::Migration[6.1]
  def change
    add_column :budget_investments, :ballot_winner, :boolean, default: false
  end
end
