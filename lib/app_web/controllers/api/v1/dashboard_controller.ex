defmodule AppWeb.Api.V1.DashboardController do
  use AppWeb, :controller

  def index(con, _params) do
    models = list()
    con
    |> json(%{models: models})
  end

  defp list, do: App.Repo.all(Similarity.Model)
end
