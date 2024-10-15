defmodule AppWeb.Api.V1.TextsController do
  use AppWeb, :controller

  def index(con, _params) do
    con
    |> json([:some, %{a: 1}])
  end

  def create(con, %{"identifier" => identifier, "name" => name, "text" => text} = params) do
    # models(params)
    id = with {:ok, prefix} <- Map.fetch(params, "prefix")
    do
      prefix <> identifier
    else
      :error ->
        identifier
    end
    real_create(con, id, name, text, params)
  end
  def create(con, %{"prefix" => prefix, "name" => name, "text" => text} = params) do
    id = prepare_id(prefix)
    real_create(con, id, name, text, params)
  end
  # def create(con, params) when is_map?(params) do
  def create(con, params) do
    con
    |> put_status(:unprocessable_entity)
    |> json(%{error: "invalid params", context: Map.keys(params)})
  end

  defp real_create(con, identifier, name, text, params) do
    # TODO: rm OK, use standard try
    
    case Api.V1.Texts.Create.call(identifier, %{name: name, text: text, models: models(params)}) do
      {:ok, res} ->
        json(con, res)
      {:error, err} ->
        con
        |> put_status(:unprocessable_entity)
        |> json(%{error: err})
    end
  end

  defp models(params) do
    with {:ok, list} <- Map.fetch(params, "models")
    do
      String.split(list, ",")
    else
      :error ->
        Similarity.Model.active
        |> Enum.map(fn m -> m.name end)
    end
  end
  defp prepare_id(prefix) do
    prefix <> UUID.uuid4(:hex)
  end
end
