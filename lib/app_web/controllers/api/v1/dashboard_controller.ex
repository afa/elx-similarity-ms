defmodule AppWeb.Api.V1.DashboardController do
  use AppWeb, :controller

  def index(con, _params) do
    con
    |> json(payload())
  end

  defp payload do
    %{
      models: models(),
      documents_total: documents_total(),
      documents_ranked: documents_ranked(),
      documents_tokenized: documents_tokenized(),
      tokens_total: tokens_total()
    }
  end

  defp models, do: Similarity.Model.active
  defp documents_total, do: Similarity.Document.total
  defp tokens_total, do: Similarity.Token.total

  defp documents_ranked do
    Similarity.Document.ranked
    |> Similarity.Document.total
  end

  defp documents_tokenized do
    Similarity.Document.tokenized
    |> Similarity.Document.total
  end
end
