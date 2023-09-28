class DebatesController < ApplicationController
  include FeatureFlags
  include CommentableActions
  include FlagActions
  include Translatable

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_view, only: :index
  before_action :debates_recommendations, only: :index, if: :current_user
  before_action :authorize_admin!, only: [:new, :create, :edit, :update, :destroy]
  before_action :load_geozones, only: [:new, :create, :edit, :update]

  feature_flag :debates

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_filters %w[current expired]
  has_orders ->(c) { Debate.debates_orders(c.current_user) }, only: :index
  has_orders %w[newest most_voted oldest], only: :show

  load_and_authorize_resource
  helper_method :resource_model, :resource_name, :is_admin?
  respond_to :html, :js

  def index_customization
    @featured_debates = @debates.featured
  end

  def is_admin?
    current_user&.administrator?
  end

  def authorize_admin!
    unless is_admin?
      redirect_to debates_path, alert: t("unauthorized.default")
    end
  end

  # def new
  #   if is_admin?
  #     # Allow admin to access the debate creation page
  #     @debate = Debate.new
  #   else
  #     redirect_to debates_path, alert: t("unauthorized.default")
  #   end
  # end
  def index
    @debates = Kaminari.paginate_array(
      Debate.send(@current_filter).sort_by_created_at
    ).page(params[:page])
  end
  def show
    super
    redirect_to debate_path(@debate), status: :moved_permanently if request.path != debate_path(@debate)
  end

  def vote
    @debate.register_vote(current_user, params[:value])
  end

  def unmark_featured
    @debate.update!(featured_at: nil)
    redirect_to debates_path
  end

  def mark_featured
    @debate.update!(featured_at: Time.current)
    redirect_to debates_path
  end

  def disable_recommendations
    if current_user.update(recommended_debates: false)
      redirect_to debates_path, notice: t("debates.index.recommendations.actions.success")
    else
      redirect_to debates_path, error: t("debates.index.recommendations.actions.error")
    end
  end

  private
    def load_geozones
      @geozones = Geozone.all.order(:name)
    end
    def debate_params
      params.require(:debate).permit(allowed_params)
    end

    def allowed_params
      [:tag_list, :terms_of_service, :related_sdg_list,  :geozone_restricted, :starts_at, :ends_at, translation_params(Debate)]
    end

    def resource_model
      Debate
    end

    def set_view
      @view = (params[:view] == "minimal") ? "minimal" : "default"
    end

    def debates_recommendations
      if Setting["feature.user.recommendations_on_debates"] && current_user.recommended_debates
        @recommended_debates = Debate.recommendations(current_user).sort_by_random.limit(3)
      end
    end
end
