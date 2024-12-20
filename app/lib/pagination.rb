# frozen_string_literal: true

require "pagy/extras/arel"

module Pagination
  include Pagy::Backend

  DEFAULT_PAGE           = 1
  DEFAULT_ITEMS_PER_PAGE = 10

  # INFO: Below constant acts as a safeguard that eliminates the risk of querying
  # tremendous amount of records from the DB by accepting any value from the API client.
  # Feel free to adjust this value to your needs (please keep it at reasonable level).
  MAX_ITEMS_PER_PAGE = 100

  def paginate(collection, params, settings = {})
    pagy(collection, pagination_params(params, collection.length, settings))
  end

  def paginate_arel(collection, params, settings = {})
    pagy_arel(collection, pagination_params(params, collection.length, settings))
  end

  private

  def pagination_params(params, collection_length, settings)
    page           = params[:page].presence || DEFAULT_PAGE
    items_per_page = [items_per_page(params, settings), MAX_ITEMS_PER_PAGE].min

    {
      items: items_per_page,
      page:  collection_length >= ((page.to_i - 1) * items_per_page.to_i) + 1 ? page : DEFAULT_PAGE,
      count: settings[:count]
    }
  end

  def items_per_page(params, settings)
    params[:items_per_page].presence || settings[:items_per_page].presence || DEFAULT_ITEMS_PER_PAGE
  end

  def pagination_data(pagination)
    {
      items_length: pagination.count,
      page:         pagination.page,
      page_count:   pagination.pages,
    }
  end
end
