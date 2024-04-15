module Budgets
  class ResultsController < ApplicationController
    before_action :load_budget
    before_action :load_heading
    before_action :load_groups

    authorize_resource :budget

    def show
      authorize! :read_results, @budget
      if params[:heading_id].present?
        @investments = Budget::Result.new(@budget, @heading, nil).investments
      elsif params[:group_id].present?
        @investments = Budget::Result.new(@budget, nil, @group).investments
        @total_votes = total_votes_in_group(@group)
      else
        @investments = Budget::Result.new(@budget, nil, @group).investments
        @total_votes = total_votes_in_group(@group)
      end

      @headings = @budget.headings.sort_by_name
      @groups = @budget.groups.sort_by_id
    end

    private

    def load_budget
      @budget = Budget.find_by_slug_or_id(params[:budget_id]) || Budget.first
    end

    def load_heading
      if @budget.present?
        headings = @budget.headings
        @heading = headings.find_by_slug_or_id(params[:heading_id]) || headings.first
      end
    end

    def load_groups
      if @budget.present?
        groups = @budget.groups
        @group = groups.find_by_slug_or_id(params[:group_id]) || groups.first
      end
    end

    def total_votes_in_group(group)
      total_votes = 0
      group.headings.each do |heading|
        heading.investments.selected.each do |investment|
          total_votes += investment.ballot_lines_count
        end
      end
      total_votes
    end
  end
end
