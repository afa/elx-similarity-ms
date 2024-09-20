defmodule AppWeb.Api.V1.RanksController do
  use AppWeb, :controller

  def show(con, %{"document_key" => _key}) do
    con
    |> json([:some, %{a: 1}])
  end
end
