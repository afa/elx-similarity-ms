defmodule Api.V1.Ranks.Show do
  @moduledoc """
  prepare result for ranks#show or :error
  TODO: add filter by model (v2?)
  """
  import Ecto.Query

  @doc """
  loads similarity ranks for active models, filtered , split by model, return json or :error
  """
  def call(key, %{models: filter}) when is_binary(key) do
    # filter = ["bm25", "tf_idf"]
    min_value = 0.0
    data = from(r in Similarity.DocumentRank,
      join: d in Similarity.Document,
      on: d.id == r.left_id or d.id == r.right_id,
      join: m in Similarity.Model,
      on: d.model_id == m.id,
      where: d.main_object == ^key and m.state == :enabled and m.name in ^filter and r.rank > ^min_value,
      select: %{rank: r.rank, id: d.id, main_object: d.main_object, model: m.name},
      order_by: [desc: r.rank])
      |> App.Repo.all
      |> Enum.group_by(fn item -> item.model end, fn item -> %{rank: item.rank, identifier: item.main_object} end)
    {:ok, %{ranks: data}}
  end
  def call(_), do: {:error, "invalid key format"}
end
