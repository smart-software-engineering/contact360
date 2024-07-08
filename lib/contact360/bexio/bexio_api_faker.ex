if Code.ensure_loaded?(Plug) do
  defmodule Contact360.Bexio.BexioApiFaker do
    @moduledoc """
    This module is responsible for faking the Bexio API in case of tests or offline access.
    """

    @doc """
    The faker does not do any tests on the validity of the data.
    """
    use Plug.Router
    use Plug.ErrorHandler

    get "/???" do
      # READ the file (json)
      # return it as is
    end
  end
end
