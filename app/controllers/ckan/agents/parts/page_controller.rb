class Ckan::Agents::Parts::PageController < ApplicationController
  include Cms::PartFilter::View

  def index
    @cur_node = @cur_part.parent
  end
end
