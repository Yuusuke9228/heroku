class Cms::PublicNoticesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Cms::Notice

  navi_view "cms/main/navi"

  private

  def set_crumbs
    @crumbs << [t("cms.notice"), action: :index]
  end

  public

  def index
    @items = @model.site(@cur_site).and_public.
      target_to(@cur_user).
      search(params[:s]).
      reorder(notice_severity: 1, released: -1).
      page(params[:page]).per(50)
  end

  def show
    raise "403" unless @model.site(@cur_site).and_public.target_to(@cur_user).find(@item.id)
    render
  end

  def frame_content
    set_item
    raise "403" unless @model.site(@cur_site).and_public.target_to(@cur_user).find(@item.id)
    render template: "sns/public_notices/frame_content", layout: false
  end
end
