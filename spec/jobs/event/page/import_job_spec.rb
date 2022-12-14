require 'spec_helper'

describe Event::Page::ImportJob, dbscope: :example do
  let!(:site) { cms_site }
  let!(:group) do
    name = 'シラサギ市/企画政策部/政策課'
    Cms::Group.where(name: name).first_or_create!(attributes_for(:cms_group, name: name))
  end
  let!(:layout) { create(:cms_layout, site: site, name: "イベントカレンダー") }
  let!(:node) { create(:event_node_page, site: site, filename: "calendar", group_ids: [ group.id ]) }
  let(:role) { create(:cms_role_admin, site_id: site.id, permissions: %w(import_private_event_pages)) }
  let(:user) { create(:cms_user, uid: unique_id, name: unique_id, group_ids: [ group.id ], role: role) }

  let!(:file_path) { "#{::Rails.root}/spec/fixtures/event/import_job/event_pages.csv" }
  let!(:in_file) { Fs::UploadedFile.create_from_file(file_path) }
  let!(:ss_file) { create(:ss_file, site: site, in_file: in_file ) }

  describe ".perform_later" do
    context "with node" do
      before do
        job_class = described_class.bind(site_id: site, node_id: node, user_id: user)
        expect { job_class.perform_now(ss_file.id) }.to output(include("import start event_pages.csv\n")).to_stdout
      end

      it do
        log = Job::Log.first
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        items = Event::Page.site(site).where(filename: /^#{node.filename}\//, depth: 2)
        expect(items.count).to be 4

        item = items.where(filename: "#{node.filename}/page1.html").first
        expect(item.name).to eq "住民相談会を開催します。"
        expect(item.layout.try(:name)).to eq "イベントカレンダー"
        expect(item.order).to be 0

        expect(item.schedule).to eq "〇〇年○月〇日"
        expect(item.venue).to eq "○○○○○○○○○○"
        expect(item.content).to eq "○○○○○○○○○○○○○○○○○○○○"
        expect(item.cost).to eq "○○○○○○○○○○"
        expect(item.related_url).to eq "http://demo.ss-proj.org/"
        expect(item.event_name).to eq "住民相談会"
        expect(item.event_dates).to eq %w(
          2016/09/07 2016/09/08 2016/09/09 2016/09/10 2016/09/11 2016/09/12 2016/09/13
          2016/09/14 2016/09/15 2016/09/16 2016/09/17 2016/09/18 2016/09/19 2016/09/20
          2016/09/21 2016/09/22 2016/09/23 2016/09/24 2016/09/25 2016/09/26 2016/09/27
        ).map { |d| d.in_time_zone.to_date }
        expect(item.event_deadline).to eq "2016/8/13".in_time_zone
        expect(item.released_type).to eq "fixed"
        expect(item.released.try(:strftime, "%Y/%m/%d %H:%M")).to eq "2016/09/07 19:11"
        expect(item.groups.pluck(:name)).to match_array ["シラサギ市/企画政策部/政策課"]
        unless SS.config.ss.disable_permission_level
          expect(item.permission_level).to be 2
        end
        expect(item.state).to eq "closed"
      end
    end
  end
end
