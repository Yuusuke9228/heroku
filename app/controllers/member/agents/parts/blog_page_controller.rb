class Member::Agents::Parts::BlogPageController < ApplicationController
  include Cms::PartFilter::View
  helper Cms::ListHelper

  def index
    @items = Member::BlogPage.public_list(site: @cur_site, part: @cur_part, date: @cur_date, request_dir: @cur_main_path).
      order_by(@cur_part.sort_hash).
      limit(@cur_part.limit)
  end
end
