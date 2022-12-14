module Member::Photo::PageFilter
  extend ActiveSupport::Concern
  include Cms::PageFilter

  private

  def render_items(cond)
    if @cur_node
      raise "403" unless @cur_node.allowed?(:read, @cur_user, site: @cur_site)
      @items = @model.site(@cur_site).node(@cur_node).
        allow(:read, @cur_user, site: @cur_site).
        search(params[:s]).
        where(cond).
        order_by(updated: -1).
        page(params[:page]).per(50)
    end
    @items = [] if !@items
    render template: "index"
  end

  public

  def index_listable
    render_items({ listable_state: "public" })
  end

  def index_slideable
    render_items({ slideable_state: "public" })
  end
end
