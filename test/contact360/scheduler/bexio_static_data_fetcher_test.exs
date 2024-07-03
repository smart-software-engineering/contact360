defmodule Contact360.Scheduler.BexioStaticDataFetcherTest do
  use ExUnit.Case, async: true

  alias Contact360.Scheduler.BexioStaticDataFetcher

  defmodule ContactFake do
    def fetch_contact_groups(_client),
      do:
        {:ok,
         %{
           93 => "A",
           78 => "I"
         }}

    def fetch_accounts(_client),
      do:
        {:ok,
         [
           %BexioApiClient.Accounting.Account{
             id: 90,
             account_no: 9900,
             name: "Korrekturen",
             account_group_id: 68,
             account_type: :complete_account,
             tax_id: nil,
             active?: true,
             locked?: true
           },
           %BexioApiClient.Accounting.Account{
             id: 93,
             account_no: 9100,
             name: "Eröffnungsbilanz",
             account_group_id: 68,
             account_type: :complete_account,
             tax_id: nil,
             active?: true,
             locked?: true
           }
         ]}
  end

  describe "fetch_contact_groups" do
    test "should try to fetch the contact groups" do
      result = BexioStaticDataFetcher.fetch_contact_groups(nil, ContactFake)
      assert result == {:ok, %{93 => "A", 78 => "I"}}
    end

    test "should try to fetch the accounts" do
      result = BexioStaticDataFetcher.fetch_accounts(nil, ContactFake)
      assert result == {:ok, %{93 => "9100: Eröffnungsbilanz", 90 => "9900: Korrekturen"}}
    end
  end
end
