# frozen_string_literal: true

module Utils
  module Services
    class InitializeDuckdbDatabase
      include DuckdbHelpers

      MACROS = [
        "CREATE OR REPLACE MACRO as_list(a) AS if(a IS NULL, [], [a]);",
        "CREATE OR REPLACE MACRO ifnull2(a, b) AS ifnull(a, b);",
        "CREATE OR REPLACE MACRO slice(a,i) AS a[i];",
        "CREATE OR REPLACE MACRO is_false(a) AS a = false;",
        "CREATE OR REPLACE MACRO is_true(a) AS a = true;",
        "CREATE OR REPLACE MACRO is_null(a) AS a IS NULL;",
        "CREATE OR REPLACE MACRO is_not_null(a) AS a IS NOT NULL;",
        "CREATE OR REPLACE MACRO as_value(a) AS if(len(a) > 1, error('unexpected collection returned'), a[1]);"
      ].freeze

      def initialize(current_session:)
        @current_session = current_session
      end

      def call
        db = DuckDB::Database.open(duckdb_path(@current_session.token))
        con = db.connect

        con.query(MACROS.join("\n"))

        con.disconnect
        db.close
      end
    end
  end
end
