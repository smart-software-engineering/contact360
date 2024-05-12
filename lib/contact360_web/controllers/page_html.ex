defmodule Contact360Web.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use Contact360Web, :html

  embed_templates "page_html/*"
end
