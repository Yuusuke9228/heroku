require 'spec_helper'

describe "article_pages", type: :feature, dbscope: :example, js: true do
  context "default release plan" do
    let(:site) { cms_site }
    let(:node) { create :article_node_page, filename: "docs", name: "article" }
    let(:index_path) { article_pages_path site.id, node }

    before { login_cms_user }

    context "with site setting" do
      before do
        site.default_release_plan_state = 'enabled'
        site.default_release_days_after = 3
        site.default_close_days_after = 100
        site.save!
      end

      it do
        Timecop.travel(Time.utc(2016, 4, 12, 10, 32)) do
          visit index_path
          click_on I18n.t('ss.links.new')

          expect(page).to have_field("item[release_date]", with: "2016/04/15 00:00")
          expect(page).to have_field("item[close_date]", with: "2016/07/21 00:00")

          within "form#item-form" do
            fill_in "item[name]", with: "sample"
            click_on I18n.t('ss.links.input')
            fill_in "item[basename]", with: "sample"
            ensure_addon_opened('#addon-cms-agents-addons-meta')
            fill_in "item[keywords]", with: "sample"
            fill_in "item[description]", with: "sample"
            click_button I18n.t("ss.buttons.publish_save")
          end
          wait_for_notice I18n.t('ss.notice.saved')

          expect(Article::Page.count).to eq 1
          item = Article::Page.first
          expect(item.state).to eq "ready"
          expect(item.release_date).to eq Time.zone.parse("2016/04/15 00:00")
          expect(item.close_date).to eq Time.zone.parse("2016/07/21 00:00")
        end
      end
    end

    context "save as draft with site setting" do
      before do
        site.default_release_plan_state = 'enabled'
        site.default_release_days_after = 3
        site.default_close_days_after = 100
        site.save!
      end

      it do
        Timecop.travel(Time.utc(2016, 4, 12, 10, 32)) do
          visit index_path
          click_on I18n.t('ss.links.new')

          expect(page).to have_field("item[release_date]", with: "2016/04/15 00:00")
          expect(page).to have_field("item[close_date]", with: "2016/07/21 00:00")

          within "form#item-form" do
            fill_in "item[name]", with: "sample"
            click_on I18n.t('ss.links.input')
            fill_in "item[basename]", with: "sample"
            ensure_addon_opened('#addon-cms-agents-addons-meta')
            fill_in "item[keywords]", with: "sample"
            fill_in "item[description]", with: "sample"
            click_button I18n.t("ss.buttons.draft_save")
          end
          wait_for_notice I18n.t('ss.notice.saved')

          expect(Article::Page.count).to eq 1
          item = Article::Page.first
          expect(item.state).to eq "closed"
          expect(item.release_date).to eq Time.zone.parse("2016/04/15 00:00")
          expect(item.close_date).to eq Time.zone.parse("2016/07/21 00:00")

          expect(page).to have_css("#workflow_route", text: I18n.t("mongoid.attributes.workflow/model/route.my_group"))
        end
      end
    end

    context "with node setting" do
      before do
        node.default_release_plan_state = 'enabled'
        node.default_release_days_after = 4
        node.default_close_days_after = 71
        node.save!
      end

      it do
        Timecop.travel(Time.utc(2016, 4, 12, 10, 32)) do
          visit index_path
          click_on I18n.t('ss.links.new')

          expect(page).to have_field("item[release_date]", with: "2016/04/16 00:00")
          expect(page).to have_field("item[close_date]", with: "2016/06/22 00:00")

          within "form#item-form" do
            fill_in "item[name]", with: "sample"
            click_on I18n.t('ss.links.input')
            fill_in "item[basename]", with: "sample"
            ensure_addon_opened('#addon-cms-agents-addons-meta')
            fill_in "item[keywords]", with: "sample"
            fill_in "item[description]", with: "sample"
            click_button I18n.t("ss.buttons.publish_save")
          end
          wait_for_notice I18n.t('ss.notice.saved')

          expect(Article::Page.count).to eq 1
          item = Article::Page.first
          expect(item.state).to eq "ready"
          expect(item.release_date).to eq Time.zone.parse("2016/04/16 00:00")
          expect(item.close_date).to eq Time.zone.parse("2016/06/22 00:00")
        end
      end
    end

    context "with site setting and node setting" do
      before do
        site.default_release_plan_state = 'enabled'
        site.default_release_days_after = 3
        site.default_close_days_after = 100
        site.save!
      end

      before do
        node.default_release_plan_state = 'enabled'
        node.default_release_days_after = 4
        node.default_close_days_after = 71
        node.save!
      end

      it do
        Timecop.travel(Time.utc(2016, 4, 12, 10, 32)) do
          visit index_path
          click_on I18n.t('ss.links.new')

          expect(page).to have_field("item[release_date]", with: "2016/04/16 00:00")
          expect(page).to have_field("item[close_date]", with: "2016/06/22 00:00")

          within "form#item-form" do
            fill_in "item[name]", with: "sample"
            click_on I18n.t('ss.links.input')
            fill_in "item[basename]", with: "sample"
            ensure_addon_opened('#addon-cms-agents-addons-meta')
            fill_in "item[keywords]", with: "sample"
            fill_in "item[description]", with: "sample"
            click_button I18n.t("ss.buttons.publish_save")
          end
          wait_for_notice I18n.t('ss.notice.saved')

          expect(Article::Page.count).to eq 1
          item = Article::Page.first
          expect(item.state).to eq "ready"
          expect(item.release_date).to eq Time.zone.parse("2016/04/16 00:00")
          expect(item.close_date).to eq Time.zone.parse("2016/06/22 00:00")
        end
      end
    end
  end
end
