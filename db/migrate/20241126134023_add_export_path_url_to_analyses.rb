class AddExportPathUrlToAnalyses < ActiveRecord::Migration[7.2]
  def change
    add_column :analyses, :export_path_url, :text
  end
end
