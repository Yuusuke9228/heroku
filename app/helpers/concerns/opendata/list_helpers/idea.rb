module Opendata::ListHelpers::Idea
  extend ActiveSupport::Concern

  def default_idea_upper_html
    app_node = Opendata::Node::App.site(@cur_site).and_public.first
    show_point = app_node.show_point?

    h = []
    h << '<table class="opendata-datasets index">'
    h << '<thead>'
    h << '<tr>'
    h << "  <th class=\"name\">#{I18n.t('opendata.labels.app_name')}</th>"
    h << "  <th class=\"updated\">#{I18n.t('opendata.labels.update_datetime')}</th>"
    h << "  <th class=\"state\">#{I18n.t('opendata.labels.state')}</th>"
    if show_point
      h << "  <th class=\"point\">#{I18n.t('opendata.labels.point')}</th>"
    end
    if dataset_enabled?
      h << "  <th class=\"dataset\">#{I18n.t('opendata.labels.dataset')}</th>"
    end
    if app_enabled?
      h << "  <th class=\"app\">#{I18n.t('opendata.labels.app')}</th>"
    end
    h << '</tr>'
    h << '</thead>'
    h << '<tbody>'

    h.join("\n")
  end

  def default_idea_lower_html
    h = []
    h << '</tbody>'
    h << '</table>'
    h.join("\n")
  end

  def render_idea_list(&block)
    cur_item = @cur_part || @cur_node
    cur_item.cur_date = @cur_date

    idea_node = Opendata::Node::Idea.site(@cur_site).and_public.first
    idea_node = Opendata::Node::Idea.site(@cur_site).first if idea_node.blank?
    return if idea_node.blank?
    show_point = idea_node.show_point?

    h = []
    h << cur_item.upper_html.presence || default_idea_upper_html

    if block
      h << capture(&block)
    else
      @items.each do |item|
        item.cur_site = @cur_site if item.respond_to?(:cur_site=) && item.site_id == @cur_site.id

        if cur_item.loop_setting.present?
          ih = item.render_template(cur_item.loop_setting.html, self)
        elsif cur_item.loop_html.present?
          ih = cur_item.render_loop_html(item)
        else
          ih = []
          ih << '<tr>'
          ih << '  <td><a href="#{idea_url}">#{idea_name}</a></td>'
          ih << '  <td>#{idea_updated}</td>'
          ih << '  <td>#{idea_state}</td>'
          if show_point
            ih << '  <td>#{idea_point}</td>'
          end
          if dataset_enabled?
            ih << '  <td>#{idea_datasets}</td>'
          end
          if app_enabled?
            ih << '  <td>#{idea_apps}</td>'
          end
          ih << '</tr>'
          ih = cur_item.render_loop_html(item, html: ih.join("\n"))
        end
        h << ih.gsub('#{current}', current_url?(item.url).to_s)
      end
    end

    h << cur_item.lower_html.presence || default_idea_lower_html

    h.join("\n").html_safe
  end
end
