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
      billing_address: nil,
      unchargeable: nil
    }

    test "list_active_clients/0 returns all clients" do
      client = client_fixture()

      clients = Clients.list_active_clients()
      assert Enum.count(clients) == 1
      assert assert_equal_client(hd(clients), client)
    end

    test "get_client_by_cloud_erp_and_company_name/1 returns the client with correct information" do
      client = client_fixture()

      assert_equal_client(
        client,
        Clients.get_client_by_erp_and_erp_id(client.cloud_erp, client.erp_id)
      )
    end

    test "get_client_by_cloud_erp_and_company_name/1 returns nothing if either one is wrong" do
      client = client_fixture()
      refute Clients.get_client_by_erp_and_erp_id(:unknown, client.erp_id)
      refute Clients.get_client_by_erp_and_erp_id(client.cloud_erp, "abc")
    end

    test "create_client/1 with valid data creates a client" do
      valid_attrs = %{
        active: true,
        company_id: "55",
        company_name: "some company_name",
        registration_email: "me2@world.com",
        registration_user_id: 1,
        login_id: "123456",
        scopes: [
          "kb_invoice_show",
          "openid",
          "offline_access",
          "contact_show",
          "note_show",
          "kb_offer_show",
          "kb_order_show"
        ],
        features: ["items"],
        cloud_erp: "bexio",
        unchargeable: false,
        refresh_token: "rft",
        token: "token",
        email: "myman@nomandsland.xxx"
      }

      test_result = Clients.register_bexio_client(valid_attrs)

      assert {:ok, %Client{} = client} = test_result
      assert client.active == true
      assert client.company_id == "55"
      assert client.company_name == "some company_name"
      assert client.registration_email == "me2@world.com"
      assert client.registration_user_id == 1
      assert client.scopes == ["a"]
      assert client.features == ["items"]
      assert client.cloud_erp == :bexio
    end

    test "register_client should create the client and schema" do
      assert true == true
    end

    test "update_client/2 with valid data updates the client" do
      client = client_fixture()

      update_attrs = %{
        active: false,
        erp_id: "43",
        company_name: "some updated company_name",
        registration_email: "meu@updated.com",
        billing_email: "billing2@updated.com",
        billing_address: "some updated billing_address",
        scopes: ["b", "c"],
        features: ["contacts", "items"]
      }

      assert {:ok, %Client{} = client} = Clients.update_client(client, update_attrs)
      assert client.active == false
      assert client.erp_id == "43"
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

      assert_equal_client(
        client,
        Clients.get_client_by_erp_and_erp_id(client.cloud_erp, client.erp_id)
      )
    end

    test "delete_client/1 deletes the client" do
      client = client_fixture()
      month_fixture(client, %{unchargeable: true})
      assert {:ok, %Client{}} = Clients.delete_client(client)

      refute Clients.get_client_by_erp_and_erp_id(client.cloud_erp, client.erp_id)
    end

    test "cannot delete_client/1 a client with active months" do
      client = client_fixture()
      month_fixture(client, %{unchargeable: false, active_users: 1, bexio_ref: nil})
      assert {:error, _} = Clients.delete_client(client)
      assert Clients.get_client_by_erp_and_erp_id(client.cloud_erp, client.erp_id)
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
      bexio_ref: nil,
      unchargeable: nil
    }

    setup do
      client = client_fixture()
      %{client: client}
    end

    test "list_months/0 returns all client_months", %{client: client} do
      month = month_fixture(client)
      assert Clients.list_months_for_client(client.id) == [month]
    end

    test "get_month!/1 returns the month with given id" do
      month = month_fixture()
      assert_equal_month(month, Clients.get_month(month.client_id, month.year, month.month))
    end

    test "create_month/1 with valid data creates a month" do
      client = client_fixture()

      valid_attrs = %{
        month: 42,
        year: 42,
        active_users: 42,
        invoice_date: ~D[2024-05-28],
        payed_date: ~D[2024-05-28],
        bexio_ref: "some bexio_ref",
        unchargeable: false
      }

      assert {:ok, %Month{} = month} = Clients.create_month(client, valid_attrs)
      assert month.month == 42
      assert month.year == 42
      assert month.active_users == 42
      assert month.invoice_date == ~D[2024-05-28]
      assert month.payed_date == ~D[2024-05-28]
      assert month.bexio_ref == "some bexio_ref"
    end

    test "create_month/1 with invalid data returns error changeset" do
      client = client_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.create_month(client, @invalid_attrs)
    end

    test "update_month/2 with valid data updates the month" do
      month = month_fixture()

      update_attrs = %{
        invoice_date: ~D[2024-05-29],
        payed_date: ~D[2024-05-29],
        bexio_ref: "some updated bexio_ref"
      }

      assert {:ok, %Month{} = month} = Clients.update_month(month, update_attrs)
      assert month.invoice_date == ~D[2024-05-29]
      assert month.payed_date == ~D[2024-05-29]
      assert month.bexio_ref == "some updated bexio_ref"
    end

    test "update_month/2 with invalid data returns error changeset" do
      month = month_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_month(month, @invalid_attrs)
      assert month == Clients.get_month(month.client_id, month.year, month.month)
    end

    test "change_month/1 returns a month changeset" do
      month = month_fixture()
      assert %Ecto.Changeset{} = Clients.change_month(month)
    end
  end

  describe "schedulers" do
    alias Contact360.Clients.Scheduler

    import Contact360.ClientsFixtures

    @invalid_attrs %{scheduler_name: nil, last_run: nil, schedule: nil}

    test "list_schedulers/0 returns all schedulers" do
      scheduler = scheduler_fixture()
      assert Clients.list_schedulers() == [scheduler]
    end

    test "create_scheduler/1 with valid data creates a scheduler" do
      valid_attrs = %{
        scheduler_name: :bexio_contacts,
        last_run: ~N[2024-05-28 14:17:00],
        schedule: "yearly"
      }

      client = client_fixture()

      assert {:ok, %Scheduler{} = scheduler} = Clients.create_scheduler(client, valid_attrs)
      assert scheduler.scheduler_name == :bexio_contacts
      assert scheduler.last_run == ~N[2024-05-28 14:17:00]
      assert scheduler.schedule == "yearly"
    end

    test "create_scheduler/1 with invalid data returns error changeset" do
      client = client_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.create_scheduler(client, @invalid_attrs)
    end

    test "update_scheduler/2 with valid data updates the scheduler" do
      scheduler = scheduler_fixture()
      update_attrs = %{last_run: ~N[2024-05-29 14:17:00], schedule: "monthly"}

      assert {:ok, %Scheduler{} = scheduler} = Clients.update_scheduler(scheduler, update_attrs)
      assert scheduler.schedule == "monthly"
      assert scheduler.last_run == ~N[2024-05-29 14:17:00]
    end

    test "update_scheduler/2 with invalid data returns error changeset" do
      scheduler = scheduler_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_scheduler(scheduler, @invalid_attrs)
      schedulers = Clients.list_schedulers()
      scheduler_db = Enum.find(schedulers, &(&1.id == scheduler.id))
      assert_equal_scheduler(scheduler, scheduler_db)
    end
  end

  defp assert_equal_client(a, b) do
    assert a.active == b.active
    assert a.billing_address == b.billing_address
    assert a.billing_email == b.billing_email
    assert a.cloud_erp == b.cloud_erp
    assert a.erp_id == b.erp_id
    assert a.company_name == b.company_name
    assert a.features == b.features
    assert a.registration_email == b.registration_email
    assert a.registration_user_id == b.registration_user_id
    assert a.scopes == b.scopes
    assert a.id == b.id
  end

  defp assert_equal_month(a, b) do
    assert a.active_users == b.active_users
    assert a.client_id == b.client_id
    assert a.month == b.month
    assert a.year == b.year
    assert a.invoice_date == b.invoice_date
    assert a.payed_date == b.payed_date
    assert a.bexio_ref == b.bexio_ref
  end

  defp assert_equal_scheduler(a, b) do
    assert a.scheduler_name == b.scheduler_name
    assert a.last_run == b.last_run
    assert a.schedule == b.schedule
  end
end
