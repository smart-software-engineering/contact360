defmodule Contact360Web.RegistrationController do
  use Contact360Web, :controller

  def step1(conn, _params) do
    render(conn, :step1, layout: false)
  end

  def step2(conn, params) do
    dbg()

    render(conn, :step2, layout: false)
  end
end
