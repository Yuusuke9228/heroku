class Inquiry::FeedbacksController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Inquiry::Column

  append_view_path "app/views/cms/pages"
  navi_view "inquiry/main/navi"
  menu_view nil

  skip_before_action :set_item
  before_action :check_permission

  private

  def fix_params
    { cur_site: @cur_site, node_id: @cur_node.id }
  end

  def check_permission
    return if @cur_site.inquiry_form_id != @cur_node.id
    raise "403" unless @cur_node.allowed?(:edit, @cur_user, site: @cur_site)
  end

  public

  def index
    if params[:s].blank?
      redirect_to action: :index, s: { year: Time.zone.today.year, month: Time.zone.today.month }
      return
    end

    raise "403" if @cur_node.route != "inquiry/form"

    options = params[:s] || {}
    options[:site] = @cur_site
    options[:node] = @cur_node
    options[:feedback] = true
    @items = @cur_node.aggregate_for_list(options)
    @items = Kaminari.paginate_array(@items.to_a).page(params[:page]).per(50)
  end

  def show
    options = params[:s] || {}
    options[:site] = @cur_site
    options[:node] = @cur_node
    options[:feedback] = true
    options[:url] = CGI.unescape(params[:id])
    @columns = @cur_node.columns.order_by(order: 1)
    @items = @cur_node.aggregate_for_list(options)
    @source_url = options[:url]
    @source_url = "#{@source_url}.#{params[:format]}" if params[:format].present?
    @source_content = Inquiry::Answer.find_content(@cur_site, @source_url)
    @answer_count = @items.first["count"]
    @aggregation = @cur_node.aggregate_select_columns(options)
    @answer_data_opts = options
  end
end
