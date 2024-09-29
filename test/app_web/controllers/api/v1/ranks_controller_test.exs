defmodule AppWeb.Api.V1.RanksControllerTest do
  use AppWeb.ConnCase, async: true

  test "GET /api/v1/ranks/test", %{conn: conn} do
    get(conn, ~p"/api/v1/ranks/test")
    |> json_response(200)
    # conn = get(conn, ~p"/api/v1/ranks/test")
    # assert json_response(conn, 200) == %{}
  end
end
