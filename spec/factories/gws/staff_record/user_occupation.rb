FactoryBot.define do
  factory :gws_staff_record_user_occupation, class: Gws::StaffRecord::UserOccupation do
    cur_site { gws_site }
    cur_user { gws_user }

    name { "name-#{unique_id}" }
    code { "code-#{unique_id}" }
    remark { "remark-#{unique_id}" }
  end
end
