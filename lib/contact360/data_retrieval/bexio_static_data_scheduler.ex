# This is a PoC Genclient_id,  in reality I need to separate the API calls and the GenServer State
defmodule Contact360.DataRetrieval.BexioStaticDataScheduler do
  use GenServer

  require Logger

  alias Contact360.DataRetrieval.BexioStaticDataFetcher

  @update_timer 1000 * 60 * 15
  @bexio_client_id Application.compile_env!(:contact360, __MODULE__)[:bexio_client_id]
  @bexio_client_secret Application.compile_env!(:contact360, __MODULE__)[:bexio_client_secret]

  ## Client API
  @doc """
  Starts a scheduler for the given client id with unique name.
  """
  def start_scheduler(client_id, token) do
    DynamicSupervisor.start_child(
      Contact360.BexioStaticDataSupervisor,
      {__MODULE__, client_id: client_id, token: token}
    )
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

  def contact_groups(client_id), do: GenServer.call(process_name(client_id), :contact_groups)
  def contact_sectors(client_id), do: GenServer.call(process_name(client_id), :contact_sectors)
  def salutations(client_id), do: GenServer.call(process_name(client_id), :salutations)
  def payment_types(client_id), do: GenServer.call(process_name(client_id), :payment_types)
  def accounts(client_id), do: GenServer.call(process_name(client_id), :accounts)
  def currencies(client_id), do: GenServer.call(process_name(client_id), :currencies)
  def languages(client_id), do: GenServer.call(process_name(client_id), :languages)
  def countries(client_id), do: GenServer.call(process_name(client_id), :countries)
  def units(client_id), do: GenServer.call(process_name(client_id), :units)
  def stock_areas(client_id), do: GenServer.call(process_name(client_id), :stock_areas)
  def stock_locations(client_id), do: GenServer.call(process_name(client_id), :stock_locations)

  ## Server API
  @impl GenServer
  def init(opts) do
    company_id = Keyword.get(opts, :company_id)
    refresh_token = Keyword.get(opts, :refresh_token)
    without_items = Keyword.get(opts, :without_items, false)

    if company_id == nil or refresh_token == nil do
      {:stop, {:missing_arguments, "Bexio Client ID and token are required"}}
    else
      trigger_self(:contact_groups, 1)
      trigger_self(:contact_sectors, 1)
      trigger_self(:salutations, 1)
      trigger_self(:payment_types, 1)
      trigger_self(:titles, 1)
      trigger_self(:accounts, 1)
      trigger_self(:currencies, 1)
      trigger_self(:languages, 1)
      trigger_self(:countries, 1)

      if not without_items do
        trigger_self(:units, 1)
        trigger_self(:stock_areas, 1)
        trigger_self(:stock_locations, 1)
      end

      # TODO: rewrite to refresh token!
      {:ok,
       %{
         company_id: company_id,
         client: BexioApiClient.new(@bexio_client_id, @bexio_client_secret, refresh_token),
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
        &BexioStaticDataFetcher.fetch_contact_groups/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :contact_sectors}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :contact_sectors,
        &BexioStaticDataFetcher.fetch_contact_sectors/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :salutations}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :salutations,
        &BexioStaticDataFetcher.fetch_salutations/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :payment_types}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :payment_types,
        &BexioStaticDataFetcher.fetch_payment_types/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :titles}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :titles,
        &BexioStaticDataFetcher.fetch_titles/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :accounts}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :accounts,
        &BexioStaticDataFetcher.fetch_accounts/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :currencies}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :currencies,
        &BexioStaticDataFetcher.fetch_currencies/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :languages}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :languages,
        &BexioStaticDataFetcher.fetch_languages/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :countries}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :countries,
        &BexioStaticDataFetcher.fetch_countries/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :units}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :units,
        &BexioStaticDataFetcher.fetch_units/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :stock_areas}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :stock_areas,
        &BexioStaticDataFetcher.fetch_stock_areas/1,
        state
      )

  @impl GenServer
  def handle_info({:fetch_data, :stock_locations}, state),
    do:
      retrieve_data_from_server_and_restart_process(
        :stock_locations,
        &BexioStaticDataFetcher.fetch_stock_locations/1,
        state
      )

  defp retrieve_data_from_server_and_restart_process(
         name,
         fetcher,
         %{client: client, client_id: client_id} = state
       ) do
    Logger.debug("Retrieving #{name} from Bexio for client with id #{client_id}.")
    trigger_self(name)

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
    {:reply, Map.fetch(state, name), state}
  end

  @impl GenServer
  def handle_call({name, id}, _from, state) when is_atom(name) do
    with {:ok, map} <- Map.fetch(state, name) do
      {:reply, Map.fetch(map, id), state}
    else
      _ -> {:reply, :error, state}
    end
  end

  defp trigger_self(name, time \\ @update_timer) do
    Process.send_after(self(), {:fetch_data, name}, time)
  end

  defp process_name(client_id), do: {:global, "bexio_static_data_scheduler_#{client_id}"}
end
