defmodule Contact360.Scheduler.BexioStaticDataFetcherTest do
  use ExUnit.Case, async: true

  alias Contact360.Scheduler.BexioStaticDataFetcher

  describe "call bexio api client" do
    setup do
      {:ok, %{client: BexioApiClient.new("123")}}
    end

    test "should try to fetch the contact groups", %{client: client} do
      result = BexioStaticDataFetcher.fetch_contact_groups(client)
      assert result == {:ok, %{93 => "A", 78 => "I"}}
    end

    test "should try to fetch the accounts", %{client: client} do
      result = BexioStaticDataFetcher.fetch_accounts(client)
      assert result == {:ok, %{93 => "9100: Eröffnungsbilanz", 90 => "9900: Korrekturen"}}
    end
  end
end
