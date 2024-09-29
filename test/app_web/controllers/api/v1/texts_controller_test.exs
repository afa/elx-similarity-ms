defmodule AppWeb.Api.V1.TextsControllerTest do
  use AppWeb.ConnCase, async: true

  test "GET /api/v1/texts/", %{conn: conn} do
    get(conn, ~p"/api/v1/texts/")
    |> json_response(200)
  end
end

