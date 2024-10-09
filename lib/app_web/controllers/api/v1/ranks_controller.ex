defmodule AppWeb.Api.V1.RanksController do
  use AppWeb, :controller
  require OK

  @moduledoc """
  API for documents ranks
  """

  @doc """
  renders limited list of the most ranked for document_key documents
  """
  def show(con, %{"document_key" => key} = params) do
    models = with {:ok, list} <- Map.fetch(params, "models")
    do
      String.split(list, ",")
    else
      :error ->
        Similarity.Model.active
        |> Enum.map(fn m -> m.name end)
    end
    OK.try do
      res <- Api.V1.Ranks.Show.call(key, %{models: models})
    after
      json(con, res)
    rescue
      _ -> con
      |> put_status(:unprocessable_entity)
      |> json(%{error: "invalid"})

    end
  end
end
