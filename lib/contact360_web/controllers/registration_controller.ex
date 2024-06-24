defmodule Contact360Web.RegistrationController do
  use Contact360Web, :controller

  import Contact360Web.RegistrationHelper

  alias Contact360.Clients

  def step1(conn, _params) do
    render(conn, :step1, layout: false)
  end

  def step2(conn, params) do
    user = get_session(conn, :user)
    company = Clients.get_client_by_erp_and_erp_id(:bexio, user.company_id)

    # validate the user and give the feedback
    valid? = valid_user_for_registration?(user)
    company_exists? = company != nil
    company_active? = company != nil and company.active? == true

    dbg()

    render(conn, :step2,
      layout: false,
      user: user,
      valid?: valid?,
      company_exists?: company_exists?,
      company_active?: company_active?
    )
  end

  defp valid_user_for_registration?(_user), do: []
end
