defmodule Contact360Web.ErrorJSONTest do
  use Contact360Web.ConnCase, async: true

  test "renders 404" do
    assert Contact360Web.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Contact360Web.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
