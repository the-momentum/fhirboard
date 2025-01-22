# frozen_string_literal: true

module DuckdbHelpers
  extend ActiveSupport::Concern

  private

  def duckdb_path(db_name)
    "lib/datasources/#{db_name}.duckdb"
  end
end
