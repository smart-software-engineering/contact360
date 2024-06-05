# This is a PoC GenServer, in reality I need to separate the API calls and the GenServer State
defmodule Contact360.DataRetrieval.BasicDataScheduler do
  use GenServer

  require Logger

  alias Contact360.DataRetrieval.BasicDataFetcher

  @update_timer 1000 * 60 * 15

  ## Client API
  @doc """
  Starts the basic data scheduler.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
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

  def contact_groups(server), do: GenServer.call(server, :contact_groups)
  def contact_sectors(server), do: GenServer.call(server, :contact_sectors)
  def salutations(server), do: GenServer.call(server, :salutations)
  def payment_types(server), do: GenServer.call(server, :payment_types)
  def accounts(server), do: GenServer.call(server, :accounts)
  def currencies(server), do: GenServer.call(server, :currencies)
  def languages(server), do: GenServer.call(server, :languages)
  def countries(server), do: GenServer.call(server, :countries)
  def units(server), do: GenServer.call(server, :units)
  def stock_areas(server), do: GenServer.call(server, :stock_areas)
  def stock_locations(server), do: GenServer.call(server, :stock_locations)

  ## Server API
  @impl GenServer
  def init(opts) do
    client_id = Keyword.get(opts, :client_id)
    token = Keyword.get(opts, :token)
    without_items = Keyword.get(opts, :without_items, false)

    if client_id == nil or token == nil do
      {:stop, {:missing_arguments, "client_id and token are required"}}
    else
      # TODO normally refresh token!
      Process.send_after(self(), {:fetch_data, :contact_groups}, 1)
      Process.send_after(self(), {:fetch_data, :contact_sectors}, 1)
      Process.send_after(self(), {:fetch_data, :salutations}, 1)
      Process.send_after(self(), {:fetch_data, :payment_types}, 1)
      Process.send_after(self(), {:fetch_data, :titles}, 1)
      Process.send_after(self(), {:fetch_data, :accounts}, 1)
      Process.send_after(self(), {:fetch_data, :currencies}, 1)
      Process.send_after(self(), {:fetch_data, :languages}, 1)
      Process.send_after(self(), {:fetch_data, :countries}, 1)

      if not without_items do
        Process.send_after(self(), {:fetch_data, :units}, 1)
        Process.send_after(self(), {:fetch_data, :stock_areas}, 1)
        Process.send_after(self(), {:fetch_data, :stock_locations}, 1)
      end

      # TODO: rewrite to refresh token!
      {:ok,
       %{
         client_id: client_id,
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
         stock_locations: %{},
         titles: %{}
       }}
    end
  end

  @impl GenServer
  def handle_info({:fetch_data, :contact_groups}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :contact_groups,
        &BasicDataFetcher.fetch_contact_groups/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :contact_sectors}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :contact_sectors,
        &BasicDataFetcher.fetch_contact_sectors/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :salutations}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :salutations,
        &BasicDataFetcher.fetch_salutations/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :payment_types}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :payment_types,
        &BasicDataFetcher.fetch_payment_types/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :titles}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :titles,
        &BasicDataFetcher.fetch_titles/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :accounts}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :accounts,
        &BasicDataFetcher.fetch_accounts/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :currencies}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :currencies,
        &BasicDataFetcher.fetch_currencies/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :languages}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :languages,
        &BasicDataFetcher.fetch_languages/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :countries}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :countries,
        &BasicDataFetcher.fetch_countries/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :units}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :units,
        &BasicDataFetcher.fetch_units/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :stock_areas}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :stock_areas,
        &BasicDataFetcher.fetch_stock_areas/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :stock_locations}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :stock_locations,
        &BasicDataFetcher.fetch_stock_locations/1,
        state
      )

  defp retrieve_data_from_server_and_restart_process(
         name,
         fetcher,
         %{client: client, client_id: client_id} = state
       ) do
    Logger.debug("Retrieving #{name} from Bexio for client with id #{client_id}.")
    Process.send_after(self(), {:fetch_data, name}, @update_timer)

    case fetcher.(client) do
      {:ok, data} ->
        {:noreply, %{state | name => data}}

      {:error, _} ->
        Logger.error(
          "Failed to retrieve #{name} from Bexio for client with id #{client_id}, retrying next time."
        )

        {:noreply, state}
    end
  end

  @impl GenServer
  def handle_call(name, _from, state) when is_atom(name) do
    {:reply, Map.fetch(state, name)}
  end

  @impl GenServer
  def handle_call({name, id}, _from, state) when is_atom(name) do
    with {:ok, map} <- Map.fetch(state, name) do
      {:reply, Map.fetch(map, id)}
    else
      _ -> {:reply, :error}
    end
  end
end
