namespace :ss do
  #
  # 5 2 * * 1 bundle exec rake ss:every_monday
  #
  task every_monday: :environment do
    Sys::HistoryArchiveJob.perform_now

    if ::SS.config.cms.disable.blank?
      ::Tasks::Cms.each_sites do |site|
        # オープンデータの履歴のアーカイブ化
        ::Tasks::SS.invoke_task("opendata:history:archive_download", site.host)
        ::Tasks::SS.invoke_task("opendata:history:archive_preview", site.host)
      end
    end
  end
end
