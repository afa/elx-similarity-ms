defmodule AppWeb.Api.V1.DashboardControllerTest do
  use AppWeb.ConnCase, async: true

  test "GET /api/v1/", %{conn: conn} do
    get(conn, ~p"/api/v1/")
    |> json_response(200)
  end
end
