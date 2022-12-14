namespace :opendata do
  task notify_dataset_plan: :environment do
    puts "Please input site: site=[www]" or exit if ENV['site'].blank?
    site = ::Cms::Site.where(host: ENV['site']).first
    ::Opendata::NotifyDatasetPlanJob.bind(site_id: site.id).perform_now
  end

  task harvest_datasets: :environment do
    puts "Please input site: site=[www]" or exit if ENV['site'].blank?

    site = ::Cms::Site.where(host: ENV['site']).first
    ::Opendata::Harvest::HarvestDatasetsJob.bind(site_id: site.id).perform_now(
      importer_id: ENV['importer'],
      exporter_id: ENV['exporter']
    )
  end

  task set_map_resources: :environment do
    puts "Please input site: site=[www]" or exit if ENV['site'].blank?
    site = ::Cms::Site.where(host: ENV['site']).first
    ids = ::Opendata::Dataset.site(site).pluck(:id)

    ids.each do |id|
      item = ::Opendata::Dataset.find(id) rescue nil
      next unless item

      item.resources.each do |resource|
        if resource.tsv_present? || resource.xls_present?
          puts "#{item.name} - #{resource.name}"
          resource.send(:save_map_resources)
          resource.set(map_resources: resource.map_resources)
        end
      end
    end
  end

  task compression_dataset: :environment do
    puts "Please input site: site=[www]" or exit if ENV['site'].blank?
    site = ::Cms::Site.where(host: ENV['site']).first
    ids = ::Opendata::Dataset.site(site).pluck(:id)

    ids.each do |id|
      item = ::Opendata::Dataset.find(id) rescue nil
      next unless item
      next unless item.public?
      puts item.name
      item.compression_dataset
    end
  end

  task check_report_and_archives: :environment do
    ::Tasks::Opendata.check_report_and_archives
  end

  namespace :harvest do
    task exporter_dataset_purge: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      puts "Please input exporter: exporter=[1]" or exit if ENV['exporter'].blank?

      site = ::Cms::Site.where(host: ENV['site']).first
      exporter = Opendata::Harvest::Exporter.site(site).where(id: ENV['exporter']).first
      exporter.dataset_purge
    end

    task exporter_group_list: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      puts "Please input exporter: exporter=[1]" or exit if ENV['exporter'].blank?

      site = ::Cms::Site.where(host: ENV['site']).first
      exporter = Opendata::Harvest::Exporter.site(site).where(id: ENV['exporter']).first
      exporter.group_list
    end

    task exporter_organization_list: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      puts "Please input exporter: exporter=[1]" or exit if ENV['exporter'].blank?

      site = ::Cms::Site.where(host: ENV['site']).first
      exporter = Opendata::Harvest::Exporter.site(site).where(id: ENV['exporter']).first
      exporter.organization_list
    end

    task exporter_initialize_organization: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      puts "Please input exporter: exporter=[1]" or exit if ENV['exporter'].blank?

      site = ::Cms::Site.where(host: ENV['site']).first
      exporter = Opendata::Harvest::Exporter.site(site).where(id: ENV['exporter']).first
      exporter.initialize_organization
    end

    task exporter_initialize_group: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      puts "Please input exporter: exporter=[1]" or exit if ENV['exporter'].blank?

      site = ::Cms::Site.where(host: ENV['site']).first
      exporter = Opendata::Harvest::Exporter.site(site).where(id: ENV['exporter']).first
      exporter.initialize_group
    end
  end

  namespace :report do
    task :generate_download, [:site] => :environment do |_task, args|
      ::Tasks::Cms.with_site(args[:site] || ENV['site']) do |site|
        Opendata::ResourceDownloadReportJob.bind(site_id: site.id).perform_now
      end
    end

    task :generate_access, [:site] => :environment do |_task, args|
      ::Tasks::Cms.with_site(args[:site] || ENV['site']) do |site|
        Opendata::DatasetAccessReportJob.bind(site_id: site.id).perform_now
      end
    end

    task :generate_preview, [:site] => :environment do |_task, args|
      ::Tasks::Cms.with_site(args[:site] || ENV['site']) do |site|
        Opendata::ResourcePreviewReportJob.bind(site_id: site.id).perform_now
      end
    end

    task :generate_all_download, [:site] => :environment do |_task, args|
      ::Tasks::Cms.with_site(args[:site] || ENV['site']) do |site|
        ::Tasks::Opendata.generate_all_download_report(site)
      end
    end

    task :generate_all_access, [:site] => :environment do |_task, args|
      ::Tasks::Cms.with_site(args[:site] || ENV['site']) do |site|
        ::Tasks::Opendata.generate_all_access_report(site)
      end
    end

    task :generate_all_preview, [:site] => :environment do |_task, args|
      ::Tasks::Cms.with_site(args[:site] || ENV['site']) do |site|
        ::Tasks::Opendata.generate_all_preview_report(site)
      end
    end
  end

  namespace :history do
    task update_all_download: :environment do
      ::Tasks::Opendata.update_all_download_history
    end

    task update_all_preview: :environment do
      ::Tasks::Opendata.update_all_preview_history
    end

    task :archive_download, [:site] => :environment do |_task, args|
      ::Tasks::Cms.with_site(args[:site] || ENV['site']) do |site|
        Opendata::ResourceDownloadHistoryArchiveJob.bind(site_id: site.id).perform_now
      end
    end

    task :archive_preview, [:site] => :environment do |_task, args|
      ::Tasks::Cms.with_site(args[:site] || ENV['site']) do |site|
        Opendata::ResourcePreviewHistoryArchiveJob.bind(site_id: site.id).perform_now
      end
    end

    task :archive_all_download, [:site] => :environment do |_task, args|
      ::Tasks::Cms.with_site(args[:site] || ENV['site']) do |site|
        ::Tasks::Opendata.archive_all_download_history(site)
      end
    end

    task :archive_all_preview, [:site] => :environment do |_task, args|
      ::Tasks::Cms.with_site(args[:site] || ENV['site']) do |site|
        ::Tasks::Opendata.archive_all_preview_history(site)
      end
    end
  end
end
