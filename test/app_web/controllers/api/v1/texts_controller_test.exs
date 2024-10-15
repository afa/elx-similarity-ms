defmodule AppWeb.Api.V1.TextsControllerTest do
  use AppWeb.ConnCase, async: true

  test "GET /api/v1/texts/", %{conn: conn} do
    get(conn, ~p"/api/v1/texts/")
    |> json_response(200)
  end

  test "POST /api/v1/texts/create", %{conn: conn} do
    post(conn, ~p"/api/v1/texts/create", %{prefix: "test", name: "", text: "test1 test2 test3\ntest4"})
    |> json_response(200)
  end
end

