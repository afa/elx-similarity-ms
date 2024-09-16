defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AppWeb.Api, as: :api do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      get "/index", DashboardController, :index
    end
  end
end
