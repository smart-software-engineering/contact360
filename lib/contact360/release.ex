defmodule Contact360.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :contact360

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
      migrate_tenant_schemas(repo)
    end
  end

  defp migrate_tenant_schemas(repo) do
    path = Application.app_dir(@app, "priv/repo/tenant_migrations")

    Triplex.all()
    |> Enum.each(&Ecto.Migrator.run(repo, path, :up, all: true, prefix: &1.prefix))
    |> IO.inspect(label: "Migrate tenant schemas")
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
    # TODO what is the result??
    Triplex.all()
    |> Ecto.Migrator.with_repo(
      repo,
      &Ecto.Migrator.run(&1, :down, to: version, prefix: &1.prefix)
    )
    |> IO.inspect(label: "Rollback tenant schemas")
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
