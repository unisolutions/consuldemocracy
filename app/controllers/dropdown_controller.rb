class DropdownController < ApplicationController
  skip_authorization_check
  before_action :set_budget

  def update_heading_options

    group_id = params[:group_id]
    # Logic to fetch heading options based on the selected group_id
    headings = @budget.headings.includes(:group).sort_by(&:name)

    if group_id.present?
      headings = headings.select { |heading| heading.group.id == group_id.to_i }
    end

    options = headings.map { |heading| [heading.name, heading.id] }

    puts json: { options: options }
    render json: { options: options }

  end

  def set_budget
    # Fetch the Budget instance based on :budget_id parameter
    @budget = Budget.find_by(id: params[:budget_id])
  end
end
