class AddSampleToAnalyses < ActiveRecord::Migration[8.0]
  def change
    add_column :analyses, :sample, :boolean, default: false
  end
end
