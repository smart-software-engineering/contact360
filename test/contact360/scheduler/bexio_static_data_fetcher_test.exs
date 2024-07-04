defmodule Contact360.Scheduler.BexioStaticDataFetcherTest do
  use ExUnit.Case, async: true

  alias Contact360.Scheduler.BexioStaticDataFetcher

  describe "fetch_contact_groups" do
    test "should try to fetch the contact groups" do
      result = BexioStaticDataFetcher.fetch_contact_groups(nil)
      assert result == {:ok, %{93 => "A", 78 => "I"}}
    end

    test "should try to fetch the accounts" do
      result = BexioStaticDataFetcher.fetch_accounts(nil)
      assert result == {:ok, %{93 => "9100: Eröffnungsbilanz", 90 => "9900: Korrekturen"}}
    end
  end
end
