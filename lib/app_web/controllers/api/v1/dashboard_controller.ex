defmodule AppWeb.Api.V1.DashboardController do
  use AppWeb, :controller

  def index(con, params) do
    con
    |> json([:some, %{a: 1}])
  end
end
