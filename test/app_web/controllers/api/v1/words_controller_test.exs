defmodule AppWeb.Api.V1.WordsControllerTest do
  use AppWeb.ConnCase, async: true

  test "GET /api/v1/words/", %{conn: conn} do
    get(conn, ~p"/api/v1/words/")
    |> json_response(200)
  end
end
