# This is a PoC Genclient_id,  in reality I need to separate the API calls and the GenServer State
defmodule Contact360.DataRetrieval.BasicDataScheduler do
  use GenServer

  require Logger

  alias Contact360.DataRetrieval.BasicDataFetcher

  @update_timer 1000 * 60 * 15

  ## Client API
  @doc """
  Starts a scheduler for the given client id with unique name.
  """
  def start_scheduler(client_id, token) do
    DynamicSupervisor.start_child(Contact360.DataRetrieval.BasicDataSupervisor, {__MODULE__, client_id: client_id, token: token})
  end

  @doc """
  Starts the basic data scheduler.
  """
  def start_link(opts \\ []) do
    client_id = Keyword.get(opts, :client_id)
    if client_id == nil do
      {:error, "client_id is required"}
    else
    GenServer.start_link(__MODULE__, Keyword.put(opts, :name, process_name(client_id)))
    end
  end

  def contact_group(client_id, id), do: GenServer.call(process_name(client_id),  {:contact_group, id})
  def contact_sector(client_id, id), do: GenServer.call(process_name(client_id),  {:contact_sector, id})
  def salutation(client_id, id), do: GenServer.call(process_name(client_id),  {:salutation, id})
  def payment_type(client_id, id), do: GenServer.call(process_name(client_id),  {:payment_type, id})
  def account(client_id, id), do: GenServer.call(process_name(client_id),  {:accounts, id})
  def currency(client_id, id), do: GenServer.call(process_name(client_id),  {:currency, id})
  def language(client_id, id), do: GenServer.call(process_name(client_id),  {:language, id})
  def country(client_id, id), do: GenServer.call(process_name(client_id),  {:country, id})
  def unit(client_id, id), do: GenServer.call(process_name(client_id),  {:unit, id})
  def stock_area(client_id, id), do: GenServer.call(process_name(client_id),  {:stock_area, id})
  def stock_location(client_id, id), do: GenServer.call(process_name(client_id),  {:stock_location, id})

  def contact_groups(client_id), do: GenServer.call(process_name(client_id),  :contact_groups)
  def contact_sectors(client_id), do: GenServer.call(process_name(client_id),  :contact_sectors)
  def salutations(client_id), do: GenServer.call(process_name(client_id),  :salutations)
  def payment_types(client_id), do: GenServer.call(process_name(client_id),  :payment_types)
  def accounts(client_id), do: GenServer.call(process_name(client_id),  :accounts)
  def currencies(client_id), do: GenServer.call(process_name(client_id),  :currencies)
  def languages(client_id), do: GenServer.call(process_name(client_id),  :languages)
  def countries(client_id), do: GenServer.call(process_name(client_id),  :countries)
  def units(client_id), do: GenServer.call(process_name(client_id),  :units)
  def stock_areas(client_id), do: GenServer.call(process_name(client_id),  :stock_areas)
  def stock_locations(client_id), do: GenServer.call(process_name(client_id),  :stock_locations)

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

  defp process_name(client_id), do: {:global, "basic_data_scheduler_#{client_id}"}
end
