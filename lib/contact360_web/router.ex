defmodule Contact360Web.Router do
  use Contact360Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Contact360Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Contact360Web do
    pipe_through :browser

    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
    post "/auth/:provider/callback", AuthController, :callback
    delete "/auth/logout", AuthController, :delete

    get "/", WelcomeController, :home
    get "/register/step1", RegistrationController, :step1
    get "/register/step2", RegistrationController, :step2
    get "/register/step3", RegistrationController, :step3
  end

  # Create a faker endpoint for Bexio Replacement
  if Application.compile_env(:contact360, :bexio_faker) do
    scope "/bexio-faker", Contact360.Bexio do
      forward "/bexio-faker", BexioFaker
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Contact360Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:contact360, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Contact360Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
