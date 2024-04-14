class Budget
  class Result
    attr_accessor :budget, :heading, :group, :current_investment

    def initialize(budget, heading, group = nil)
      @budget = budget
      @heading = heading
      @group = group
    end

    def calculate_winners
      reset_winners
      if @budget.hide_money?
        investments.compatible.update_all(winner: true)
      else
        investments.compatible.each do |investment|
          @current_investment = investment
          set_winner if inside_budget?
        end
      end
    end

    def investments
      if group != nil
        investments = []
        group.headings.each do |heading|
          investments.concat(heading.investments.selected)
        end
        investments.sort_by { |investment| [investment.ballot_winner ? 0 : 1, -investment.ballot_lines_count, -investment.id] }
      else
        heading.investments.selected.sort_by_ballots
      end

    end

    def inside_budget?
      available_budget >= @current_investment.price
    end

    def available_budget
      total_budget - money_spent
    end

    def total_budget
      heading.price
    end

    def money_spent
      @money_spent ||= 0
    end

    def reset_winners
      investments.update_all(winner: false)
    end

    def set_winner
      @money_spent += @current_investment.price
      @current_investment.update!(winner: true)
    end

    def winners
      investments.where(winner: true)
    end
  end
end
