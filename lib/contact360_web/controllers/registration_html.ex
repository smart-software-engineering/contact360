defmodule Contact360Web.RegistrationHTML do
  @moduledoc """
  This module contains pages rendered by RegistrationController.

  See the `registration_html` directory for all templates available.
  """
  use Contact360Web, :html

  import Contact360Web.RegistrationHelper

  embed_templates "registration_html/*"
end
