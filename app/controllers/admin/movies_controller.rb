module Admin
  class MoviesController < BaseController
    before_action :set_movie, only: %i[show edit update destroy]

    def index
      @movies = Movie.order(:title).with_attached_poster
      @movies = @movies.where(status: params[:status]) if Movie.statuses.key?(params[:status])
    end

    def show
      @screenings = @movie.screenings.upcoming.chronological.includes(hall: :cinema)
    end

    def new
      @movie = Movie.new
    end

    def create
      @movie = Movie.new(movie_params)
      if @movie.save
        redirect_to admin_movie_path(@movie), notice: "Película creada."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @movie.update(movie_params)
        redirect_to admin_movie_path(@movie), notice: "Película actualizada."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      destroy_record(@movie, admin_movies_path)
    end

    private

    def set_movie
      @movie = Movie.find(params[:id])
    end

    def movie_params
      params.expect(movie: %i[title synopsis genre duration_minutes rating status release_date poster])
    end
  end
end
