defmodule AppWeb.Api.V1.RanksControllerTest do
  use AppWeb.ConnCase, async: true

  test "GET /api/v1/ranks/test", %{conn: conn} do
    conn = get(conn, ~p"/api/v1/ranks/test")
    assert json_response(conn, 200) == %{}
  end

  # test "renders 404" do
  #   assert AppWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  # end

  # test "renders 500" do
  #   assert AppWeb.ErrorJSON.render("500.json", %{}) ==
  #            %{errors: %{detail: "Internal Server Error"}}
  # end
end
