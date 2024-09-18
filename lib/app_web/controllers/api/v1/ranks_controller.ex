defmodule AppWeb.Api.V1.RanksController do
  use AppWeb, :controller

  def index(con, %{"document_key" => key}) do
    
    con
    |> json([:some, %{a: 1}])
  end
end
