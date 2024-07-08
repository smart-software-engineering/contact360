defmodule Contact360.Scheduler.BexioStaticDataFetcher do
  @moduledoc """
  This module is responsible for fetching static data from the Bexio API.
  """

  def fetch_contact_groups(client), do: BexioApiClient.Contacts.fetch_contact_groups(client)

  def fetch_contact_sectors(client), do: BexioApiClient.Contacts.fetch_contact_sectors(client)

  def fetch_salutations(client), do: BexioApiClient.Contacts.fetch_salutations(client)

  def fetch_payment_types(client), do: BexioApiClient.Others.fetch_payment_types(client)

  def fetch_titles(client), do: BexioApiClient.Contacts.fetch_titles(client)

  def fetch_accounts(client) do
    case BexioApiClient.Accounting.fetch_accounts(client) do
      {:ok, accounts} -> {:ok, remap_accounts_into_map(accounts)}
      x -> x
    end
  end

  defp remap_accounts_into_map(accounts) do
    accounts
    |> Enum.map(fn %{
                     id: id,
                     account_no: account_no,
                     name: name
                   } ->
      {id, "#{account_no}: #{name}"}
    end)
    |> Enum.into(%{})
  end

  def fetch_currencies(client) do
    case BexioApiClient.Accounting.fetch_currencies(client) do
      {:ok, currencies} -> {:ok, remap_currencies_into_currencies(currencies)}
      x -> x
    end
  end

  defp remap_currencies_into_currencies(currencies) do
    currencies
    |> Enum.map(fn %{
                     id: id,
                     name: name
                   } ->
      {id, name}
    end)
    |> Enum.into(%{})
  end

  def fetch_languages(client) do
    case BexioApiClient.Others.fetch_languages(client) do
      {:ok, languages} -> {:ok, remap_languages_into_map(languages)}
      x -> x
    end
  end

  defp remap_languages_into_map(languages) do
    languages
    |> Enum.map(fn %{
                     id: id,
                     name: name
                   } ->
      {id, name}
    end)
    |> Enum.into(%{})
  end

  def fetch_countries(client) do
    case BexioApiClient.Others.fetch_countries(client) do
      {:ok, countries} -> {:ok, remap_countries_into_map(countries)}
      x -> x
    end
  end

  defp remap_countries_into_map(countries) do
    countries
    |> Enum.map(fn %{
                     id: id,
                     name: name,
                     iso_3166_alpha2: iso_3266_alpha2
                   } ->
      {id, "#{name} (#{iso_3266_alpha2})"}
    end)
    |> Enum.into(%{})
  end

  def fetch_units(client), do: BexioApiClient.Others.fetch_units(client)

  def fetch_permissions(token),
    do: create_token_client(token) |> BexioApiClient.Others.get_access_information()

  def fetch_company_profiles(token),
    do: create_token_client(token) |> BexioApiClient.Others.fetch_company_profiles()

  defp create_token_client(token), do: BexioApiClient.new(token)
end
