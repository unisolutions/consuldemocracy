class Budgets::Investments::InfoComponent < ApplicationComponent
  include BudgetInvestmentsHelper
  attr_reader :investment

  def initialize(investment)
    @investment = investment
  end
end
