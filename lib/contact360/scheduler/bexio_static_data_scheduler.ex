# TODO rewrite this into a supervisor and every scheduler into a genserver...
defmodule Contact360.Scheduler.BexioStaticDataScheduler do
  @moduledoc """
  This module defines all functionality that is needed to load static data from bexio per client. While currently self-triggering
  with schedulers this part will be replaced by Oban.

  TODO: Replace scheduler with Oban.
  TODO: Should trigger an event to update the data in the database.
  """

  use GenServer, restart: :transient

  alias Contact360.Scheduler.BexioStaticDataFetcher

  require Logger

  @update_timer 1000 * 60 * 15

  ## Client API
  @doc """
  Starts the basic data scheduler.
  """
  def start_link(opts \\ []) do
    company_id = Keyword.get(opts, :company_id)
    refresh_token = Keyword.get(opts, :refresh_token)

    if company_id == nil or refresh_token == nil do
      {:error, "company_id and refresh_token are required"}
    else
      GenServer.start_link(__MODULE__, Keyword.put(opts, :name, process_name(company_id)))
    end
  end

  def stop_process(company_id) do
    GenServer.call(process_name(company_id), :stop)
  end

  def contact_groups(company_id), do: GenServer.call(process_name(company_id), :contact_groups)
  def contact_sectors(company_id), do: GenServer.call(process_name(company_id), :contact_sectors)
  def salutations(company_id), do: GenServer.call(process_name(company_id), :salutations)
  def payment_types(company_id), do: GenServer.call(process_name(company_id), :payment_types)
  def accounts(company_id), do: GenServer.call(process_name(company_id), :accounts)
  def currencies(company_id), do: GenServer.call(process_name(company_id), :currencies)
  def languages(company_id), do: GenServer.call(process_name(company_id), :languages)
  def countries(company_id), do: GenServer.call(process_name(company_id), :countries)
  def units(company_id), do: GenServer.call(process_name(company_id), :units)

  ## Server API
  @impl GenServer
  def init(opts) do
    company_id = Keyword.get(opts, :company_id)
    refresh_token = Keyword.get(opts, :refresh_token)
    without_items = Keyword.get(opts, :without_items, false)

    if company_id == nil or refresh_token == nil do
      {:stop, {:missing_arguments, "Bexio Company ID and token are required"}}
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
      end

      {:ok,
       %{
         company_id: company_id,
         client: BexioApiClient.new(bexio_client_id(), bexio_client_secret(), refresh_token),
         contact_groups: %{},
         contact_sectors: %{},
         salutations: %{},
         payment_types: %{},
         accounts: %{},
         currencies: %{},
         languages: %{},
         countries: %{},
         units: %{},
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

  defp retrieve_data_from_server_and_restart_process(
         name,
         fetcher,
         %{client: client, company_id: company_id} = state
       ) do
    Logger.debug("Retrieving #{name} from Bexio for client with id #{company_id}.")
    trigger_self(name)

    case fetcher.(client) do
      {:ok, data} ->
        {:noreply, %{state | name => data}}

      {:error, _} ->
        Logger.error(
          "Failed to retrieve #{name} from Bexio for client with id #{company_id}, retrying next time."
        )

        {:noreply, state}
    end
  end

  @impl GenServer
  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_call(name, _from, state) when is_atom(name) do
    {:reply, Map.fetch(state, name), state}
  end

  @impl GenServer
  def handle_call({name, id}, _from, state) when is_atom(name) do
    case Map.fetch(state, name) do
      {:ok, map} -> {:reply, Map.fetch(map, id), state}
      :error -> {:reply, :error, state}
    end
  end

  defp trigger_self(name, time \\ @update_timer) do
    Process.send_after(self(), {:fetch_data, name}, time)
  end

  def process_name(company_id),
    do: {:via, Registry, {Contact360.Registry, "bexio_static_data_scheduler_#{company_id}"}}

  defp bexio_client_id, do: Application.fetch_env!(:contact360, __MODULE__)[:bexio_client_id]

  defp bexio_client_secret,
    do: Application.fetch_env!(:contact360, __MODULE__)[:bexio_client_secret]
end
