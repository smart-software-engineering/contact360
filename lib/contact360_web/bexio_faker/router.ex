defmodule Contact360Web.BexioFaker.Router do
  use Contact360Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Contact360Web.BexioFaker do
    pipe_through :api

    get "/company_profile", Others, :company_profile
  end
end
