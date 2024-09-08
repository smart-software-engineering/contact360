defmodule Contact360Web.BexioFaker.Others do
  use Contact360Web, :controller

  def company_profile(conn, _params) do
    IO.inspect(_params, label: "Params")
    render(conn, %{})
  end
end
