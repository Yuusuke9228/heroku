module Cms::MicheckerFilter
  extend ActiveSupport::Concern

  def michecker
    raise '404' unless michecker_enabled?
    raise '403' unless @cur_user.cms_role_permit_any?(@cur_site, :use_cms_michecker)

    set_item
    @result = Cms::Michecker::Result.site(@cur_site).and_page(@item).reorder(id: -1).first

    if @result && ::File.exist?(@result.html_checker_report_filepath)
      @accessibility_result = Cms::Michecker::Accessibility.load(@result.html_checker_report_filepath)
    end
    if @result && ::File.exist?(@result.low_vision_report_filepath)
      @lowvision_result = Cms::Michecker::LowVision.load(@result.low_vision_report_filepath)
    end

    render template: "michecker", layout: "cms/michecker"
  end

  def michecker_start
    set_item

    type = @item.is_a?(Cms::Model::Page) ? "page" : "node"
    job_class = Cms::MicheckerJob.bind(site_id: @cur_site, node_id: @cur_node, user_id: @cur_user)
    job = job_class.perform_later(type, @item.id.to_s)
    json = { job_id: job.job_id, status_check_url: job_sns_apis_status_path(id: job.job_id, format: "json") }
    render json: json, status: :ok
  end

  def michecker_result
    set_item
    @result = Cms::Michecker::Result.site(@cur_site).and_page(@item).reorder(id: -1).first

    case params[:type].to_s
    when "accessibility_report"
      michecker_result_accessibility_report
    when "lowvision_report"
      michecker_result_lowvision_report
    when "lowvision_source"
      michecker_result_lowvision_source
    when "lowvision_result"
      michecker_result_lowvision_result
    else
      raise "404"
    end
  end

  def michecker_enabled?
    return false if SS.config.michecker.blank?
    SS.config.michecker['disable'].blank?
  end

  private

  def michecker_result_accessibility_report
    if @result && ::File.exist?(@result.html_checker_report_filepath)
      @accessibility_result = Cms::Michecker::Accessibility.load(@result.html_checker_report_filepath)
    end

    respond_to do |format|
      format.html { render(template: "michecker_accessibility_report", layout: false) }
      format.csv do
        if @accessibility_result.blank?
          response.status = 404
          break
        end

        filename = "accessibility_report_#{Time.zone.now.to_i}.csv"

        response.status = 200
        enum = @accessibility_result.enum_csv(encoding: "UTF-8")
        send_enum enum, type: enum.content_type, filename: filename
      end
    end
  end

  def michecker_result_lowvision_report
    if @result && ::File.exist?(@result.low_vision_report_filepath)
      @lowvision_result = Cms::Michecker::LowVision.load(@result.low_vision_report_filepath)
    end

    respond_to do |format|
      format.html { render template: "michecker_lowvision_report", layout: false }
      format.csv do
        if @lowvision_result.blank?
          response.status = 404
          break
        end

        filename = "low_vision_report_#{Time.zone.now.to_i}.csv"

        response.status = 200
        enum = @lowvision_result.enum_csv(encoding: "UTF-8")
        send_enum enum, type: enum.content_type, filename: filename
      end
    end
  end

  def michecker_result_lowvision_source
    file = @result.low_vision_source_filepath
    raise "404" if file.blank? || !::File.exist?(file)

    ss_send_file file
  end

  def michecker_result_lowvision_result
    file = @result.low_vision_result_filepath
    raise "404" if file.blank? || !::File.exist?(file)

    ss_send_file file
  end
end
