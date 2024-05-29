defmodule Contact360.ClientsTest do
  use Contact360.DataCase

  alias Contact360.Clients

  describe "clients" do
    alias Contact360.Clients.Client

    import Contact360.ClientsFixtures

    @invalid_attrs %{
      active: nil,
      company_id: nil,
      company_name: nil,
      registration_email: nil,
      billing_email: nil,
      billing_address: nil
    }

    test "list_clients/0 returns all clients" do
      client = client_fixture()
      assert Clients.list_clients() == [client]
    end

    test "get_client!/1 returns the client with given id" do
      client = client_fixture()
      assert Clients.get_client!(client.id) == client
    end

    test "create_client/1 with valid data creates a client" do
      valid_attrs = %{
        active: true,
        company_id: 55,
        company_name: "some company_name",
        registration_email: "me2@world.com",
        registration_user_id: 1,
        scopes: ["a"],
        features: ["items"],
        cloud_erp: "bexio"
      }

      assert {:ok, %Client{} = client} = Clients.create_client(valid_attrs)
      assert client.active == true
      assert client.company_id == 55
      assert client.company_name == "some company_name"
      assert client.registration_email == "me2@world.com"
      assert client.registration_user_id == 1
      assert client.scopes == ["a"]
      assert client.features == ["items"]
      assert client.cloud_erp == :bexio
    end

    test "create_client/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_client(@invalid_attrs)
    end

    test "update_client/2 with valid data updates the client" do
      client = client_fixture()

      update_attrs = %{
        active: false,
        company_id: 43,
        company_name: "some updated company_name",
        registration_email: "meu@updated.com",
        billing_email: "billing2@updated.com",
        billing_address: "some updated billing_address",
        scopes: ["b", "c"],
        features: ["contacts", "items"]
      }

      assert {:ok, %Client{} = client} = Clients.update_client(client, update_attrs)
      assert client.active == false
      assert client.company_id == 43
      assert client.company_name == "some updated company_name"
      assert client.registration_email == "meu@updated.com"
      assert client.billing_email == "billing2@updated.com"
      assert client.billing_address == "some updated billing_address"
      assert client.scopes == ["b", "c"]
      assert client.features == ["contacts", "items"]
    end

    test "update_client/2 with invalid data returns error changeset" do
      client = client_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_client(client, @invalid_attrs)
      assert client == Clients.get_client!(client.id)
    end

    test "delete_client/1 deletes the client" do
      client = client_fixture()
      assert {:ok, %Client{}} = Clients.delete_client(client)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_client!(client.id) end
    end

    test "change_client/1 returns a client changeset" do
      client = client_fixture()
      assert %Ecto.Changeset{} = Clients.change_client(client)
    end
  end

  describe "client_months" do
    alias Contact360.Clients.Month

    import Contact360.ClientsFixtures

    @invalid_attrs %{
      month: nil,
      year: nil,
      active_users: nil,
      invoice_date: nil,
      payed_date: nil,
      bexio_ref: nil
    }

    setup do
      client = client_fixture()
      %{client: client}
    end

    test "list_client_months/0 returns all client_months", %{client: client} do
      IO.inspect(client, label: "Client")
      month = month_fixture(%{client_id: client.id})
      assert Clients.list_client_months() == [month]
    end

    @tag :pending
    test "get_month!/1 returns the month with given id" do
      month = month_fixture()
      assert Clients.get_month!(month.id) == month
    end

    @tag :pending
    test "create_month/1 with valid data creates a month" do
      valid_attrs = %{
        month: 42,
        year: 42,
        active_users: 42,
        invoice_date: ~D[2024-05-28],
        payed_date: ~D[2024-05-28],
        bexio_ref: "some bexio_ref"
      }

      assert {:ok, %Month{} = month} = Clients.create_month(valid_attrs)
      assert month.month == 42
      assert month.year == 42
      assert month.active_users == 42
      assert month.invoice_date == ~D[2024-05-28]
      assert month.payed_date == ~D[2024-05-28]
      assert month.bexio_ref == "some bexio_ref"
    end

    @tag :pending
    test "create_month/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_month(@invalid_attrs)
    end

    @tag :pending
    test "update_month/2 with valid data updates the month" do
      month = month_fixture()

      update_attrs = %{
        month: 43,
        year: 43,
        active_users: 43,
        invoice_date: ~D[2024-05-29],
        payed_date: ~D[2024-05-29],
        bexio_ref: "some updated bexio_ref"
      }

      assert {:ok, %Month{} = month} = Clients.update_month(month, update_attrs)
      assert month.month == 43
      assert month.year == 43
      assert month.active_users == 43
      assert month.invoice_date == ~D[2024-05-29]
      assert month.payed_date == ~D[2024-05-29]
      assert month.bexio_ref == "some updated bexio_ref"
    end

    @tag :pending
    test "update_month/2 with invalid data returns error changeset" do
      month = month_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_month(month, @invalid_attrs)
      assert month == Clients.get_month!(month.id)
    end

    @tag :pending
    test "delete_month/1 deletes the month" do
      month = month_fixture()
      assert {:ok, %Month{}} = Clients.delete_month(month)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_month!(month.id) end
    end

    @tag :pending
    test "change_month/1 returns a month changeset" do
      month = month_fixture()
      assert %Ecto.Changeset{} = Clients.change_month(month)
    end
  end

  describe "schedulers" do
    alias Contact360.Clients.Scheduler

    import Contact360.ClientsFixtures

    @invalid_attrs %{scheduler_name: nil, last_run: nil}

    @tag :pending
    test "list_schedulers/0 returns all schedulers" do
      scheduler = scheduler_fixture()
      assert Clients.list_schedulers() == [scheduler]
    end

    @tag :pending
    test "get_scheduler!/1 returns the scheduler with given id" do
      scheduler = scheduler_fixture()
      assert Clients.get_scheduler!(scheduler.id) == scheduler
    end

    @tag :pending
    test "create_scheduler/1 with valid data creates a scheduler" do
      valid_attrs = %{scheduler_name: :bexio_contacts, last_run: ~N[2024-05-28 14:17:00]}

      assert {:ok, %Scheduler{} = scheduler} = Clients.create_scheduler(valid_attrs)
      assert scheduler.scheduler_name == :bexio_contacts
      assert scheduler.last_run == ~N[2024-05-28 14:17:00]
    end

    @tag :pending
    test "create_scheduler/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_scheduler(@invalid_attrs)
    end

    @tag :pending
    test "update_scheduler/2 with valid data updates the scheduler" do
      scheduler = scheduler_fixture()
      update_attrs = %{scheduler_name: :bexio_items, last_run: ~N[2024-05-29 14:17:00]}

      assert {:ok, %Scheduler{} = scheduler} = Clients.update_scheduler(scheduler, update_attrs)
      assert scheduler.scheduler_name == :bexio_items
      assert scheduler.last_run == ~N[2024-05-29 14:17:00]
    end

    @tag :pending
    test "update_scheduler/2 with invalid data returns error changeset" do
      scheduler = scheduler_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_scheduler(scheduler, @invalid_attrs)
      assert scheduler == Clients.get_scheduler!(scheduler.id)
    end

    @tag :pending
    test "delete_scheduler/1 deletes the scheduler" do
      scheduler = scheduler_fixture()
      assert {:ok, %Scheduler{}} = Clients.delete_scheduler(scheduler)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_scheduler!(scheduler.id) end
    end

    @tag :pending
    test "change_scheduler/1 returns a scheduler changeset" do
      scheduler = scheduler_fixture()
      assert %Ecto.Changeset{} = Clients.change_scheduler(scheduler)
    end
  end
end
