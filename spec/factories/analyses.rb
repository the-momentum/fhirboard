# == Schema Information
#
# Table name: analyses
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  description     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  export_path_url :text
#  session_id      :integer
#
# Indexes
#
#  index_analyses_on_session_id  (session_id)
#

FactoryBot.define do
  factory :analysis do
    name { "MyString" }
    description { "MyText" }
    export_path_url { "MyText" }
  end
end
