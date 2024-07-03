defmodule Contact360Web.WelcomeHTML do
  @moduledoc """
  This module contains pages rendered by WelcomeController.

  See the `welcome_html` directory for all templates available.
  """
  use Contact360Web, :html

  embed_templates "welcome_html/*"
end
