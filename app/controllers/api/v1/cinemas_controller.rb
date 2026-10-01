module Api
  module V1
    class CinemasController < BaseController
      # GET /api/v1/cinemas
      def index
        @cinemas = Cinema.order(:name)
      end
    end
  end
end
