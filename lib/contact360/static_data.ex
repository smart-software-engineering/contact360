# This is a PoC GenServer, in reality I need to separate the API calls and the GenServer State
defmodule Contact360.BasicDataScheduler do
  use GenServer

  require Logger

  @update_timer 1000 * 60 * 15

  ## Client API
  @doc """
  Starts the basic data scheduler.
  """
  def start_link(token, opts \\ []) do
    without_items = Keyword.get(opts, :without_items, false)

    GenServer.start_link(__MODULE__, {token, without_items}, opts)
  end

  def contact_group(server, id), do: GenServer.call(server, {:contact_group, id})
  def contact_sector(server, id), do: GenServer.call(server, {:contact_sector, id})
  def salutation(server, id), do: GenServer.call(server, {:salutation, id})
  def payment_type(server, id), do: GenServer.call(server, {:payment_type, id})
  def account(server, id), do: GenServer.call(server, {:accounts, id})
  def currency(server, id), do: GenServer.call(server, {:currency, id})
  def language(server, id), do: GenServer.call(server, {:language, id})
  def country(server, id), do: GenServer.call(server, {:country, id})
  def unit(server, id), do: GenServer.call(server, {:unit, id})
  def stock_area(server, id), do: GenServer.call(server, {:stock_area, id})
  def stock_location(server, id), do: GenServer.call(server, {:stock_location, id})

  ## Server API
  @impl GenServer
  def init({token, without_items}) do
    # TODO normally refresh token!
    Process.send_after(self(), :contact_groups, 1)
    Process.send_after(self(), :contact_sectors, 1)
    Process.send_after(self(), :salutations, 1)
    Process.send_after(self(), :payment_types, 1)
    Process.send_after(self(), :titles, 1)
    Process.send_after(self(), :accounts, 1)
    Process.send_after(self(), :currencies, 1)
    Process.send_after(self(), :languages, 1)
    Process.send_after(self(), :countries, 1)

    if not without_items do
      Process.send_after(self(), :units, 1)
      Process.send_after(self(), :stock_areas, 1)
      Process.send_after(self(), :stock_locations, 1)
    end

    {:ok,
     %{
       client: BexioApiClient.new(token),
       contact_groups: %{},
       contact_sectors: %{},
       salutations: %{},
       payment_types: %{},
       accounts: %{},
       currencies: %{},
       languages: %{},
       countries: %{},
       units: %{},
       stock_areas: %{},
       stock_locations: %{}
     }}
  end

  @impl GenServer
  def handle_info(:contact_groups, state) do
    fetch_store_and_time(state, :contact_groups, &BexioApiClient.Contacts.fetch_contact_groups/1)
  end

  @impl GenServer
  def handle_info(:contact_sectors, state) do
    fetch_store_and_time(
      state,
      :contact_sectors,
      &BexioApiClient.Contacts.fetch_contact_sectors/1
    )
  end

  @impl GenServer
  def handle_info(:salutations, state) do
    fetch_store_and_time(state, :salutations, &BexioApiClient.Contacts.fetch_salutations/1)
  end

  @impl GenServer
  def handle_info(:payment_types, state) do
    fetch_store_and_time(state, :payment_types, &BexioApiClient.Others.fetch_payment_types/1)
  end

  @impl GenServer
  def handle_info(:titles, state) do
    fetch_store_and_time(state, :titles, &BexioApiClient.Contacts.fetch_titles/1)
  end

  @impl GenServer
  def handle_info(:accounts, state) do
    fetch_store_and_time(
      state,
      :accounts,
      &BexioApiClient.Accounting.fetch_accounts/1,
      &remap_accounts/1
    )
  end

  @impl GenServer
  def handle_info(:currencies, state) do
    fetch_store_and_time(
      state,
      :currencies,
      &BexioApiClient.Accounting.fetch_currencies/1,
      &remap_currencies/1
    )
  end

  @impl GenServer
  def handle_info(:languages, state) do
    fetch_store_and_time(
      state,
      :languages,
      &BexioApiClient.Others.fetch_languages/1,
      &remap_languages/1
    )
  end

  @impl GenServer
  def handle_info(:countries, state) do
    fetch_store_and_time(
      state,
      :countries,
      &BexioApiClient.Others.fetch_countries/1,
      &remap_countries/1
    )
  end

  @impl GenServer
  def handle_info(:units, state) do
    fetch_store_and_time(
      state,
      :units,
      &BexioApiClient.Others.fetch_units/1
    )
  end

  @impl GenServer
  def handle_info(:stock_areas, state) do
    fetch_store_and_time(
      state,
      :stock_areas,
      &BexioApiClient.Items.fetch_stock_areas/1
    )
  end

  @impl GenServer
  def handle_info(:stock_locations, state) do
    fetch_store_and_time(
      state,
      :stock_locations,
      &BexioApiClient.Items.fetch_stock_locations/1
    )
  end

  defp fetch_store_and_time(
         %{client: client} = state,
         bag,
         fetch_fun,
         remap_function \\ &Function.identity/1
       ) do
    Process.send_after(self(), bag, @update_timer)

    case(fetch_fun.(client)) do
      {:ok, new_information} ->
        {:noreply,
         Map.put(
           state,
           bag,
           remap_function.(new_information)
         )}

      {:error, error} ->
        Logger.error("Could not fetch #{bag}, try again next time: #{inspect(error)}")
        {:noreply, state}
    end
  end

  defp remap_accounts(accounts),
    do:
      accounts
      |> Enum.map(fn %BexioApiClient.Accounting.Account{
                       id: id,
                       account_no: account_no,
                       name: name
                     } ->
        {id, "#{account_no}: #{name}"}
      end)
      |> Enum.into(%{})

  defp remap_currencies(currencies),
    do:
      currencies
      |> Enum.map(fn %BexioApiClient.Accounting.Currency{
                       id: id,
                       name: name
                     } ->
        {id, name}
      end)
      |> Enum.into(%{})

  defp remap_countries(countries),
    do:
      countries
      |> Enum.map(fn %BexioApiClient.Others.Country{
                       id: id,
                       name: name,
                       name_short: name_short,
                       iso_3166_alpha2: iso_3266_alpha2
                     } ->
        {id, "#{name} (#{name_short} / #{iso_3266_alpha2})"}
      end)
      |> Enum.into(%{})

  defp remap_languages(languages),
    do:
      languages
      |> Enum.map(fn %BexioApiClient.Others.Language{
                       id: id,
                       name: name
                     } ->
        {id, name}
      end)
      |> Enum.into(%{})

  @impl GenServer
  def handle_call({:contact_group, id}, _from, %{contact_groups: contact_groups} = state) do
    {:reply, Map.fetch(contact_groups, id), state}
  end

  @impl GenServer
  def handle_call({:contact_sector, id}, _from, %{contact_sectors: contact_sectors} = state) do
    {:reply, Map.fetch(contact_sectors, id), state}
  end

  @impl GenServer
  def handle_call({:salutation, id}, _from, %{salutations: salutations} = state) do
    {:reply, Map.fetch(salutations, id), state}
  end

  @impl GenServer
  def handle_call({:payment_type, id}, _from, %{payment_types: payment_types} = state) do
    {:reply, Map.fetch(payment_types, id), state}
  end

  @impl GenServer
  def handle_call({:title, id}, _from, %{titles: titles} = state) do
    {:reply, Map.fetch(titles, id), state}
  end

  @impl GenServer
  def handle_call({:account, id}, _from, %{accounts: accounts} = state) do
    {:reply, Map.fetch(accounts, id), state}
  end

  @impl GenServer
  def handle_call({:currency, id}, _from, %{currencies: currencies} = state) do
    {:reply, Map.fetch(currencies, id), state}
  end

  @impl GenServer
  def handle_call({:language, id}, _from, %{languages: languages} = state) do
    {:reply, Map.fetch(languages, id), state}
  end

  @impl GenServer
  def handle_call({:country, id}, _from, %{countries: countries} = state) do
    {:reply, Map.fetch(countries, id), state}
  end

  @impl GenServer
  def handle_call({:unit, id}, _from, %{units: units} = state) do
    {:reply, Map.fetch(units, id), state}
  end

  @impl GenServer
  def handle_call({:stock_area, id}, _from, %{stock_areas: stock_areas} = state) do
    {:reply, Map.fetch(stock_areas, id), state}
  end

  @impl GenServer
  def handle_call({:stock_location, id}, _from, %{stock_locations: stock_locations} = state) do
    {:reply, Map.fetch(stock_locations, id), state}
  end

  @impl GenServer
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end
end
