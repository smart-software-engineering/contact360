defmodule Contact360Web.AuthHTML do
  @moduledoc """
  This module contains pages rendered by AuthController.

  See the `auth_html` directory for all templates available.
  """
  use Contact360Web, :html

  embed_templates "auth_html/*"
end
