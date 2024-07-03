defmodule Contact360.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :contact360

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _fun_return, _apps} =
        Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))

      migrate_tenant_schemas(repo)
    end
  end

  defp migrate_tenant_schemas(repo) do
    path = Application.app_dir(@app, "priv/repo/tenant_migrations")

    Ecto.Migrator.with_repo(repo, fn repo ->
      Triplex.all(repo)
      |> Enum.map(&Ecto.Migrator.run(repo, path, :up, all: true, prefix: &1))
    end)
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _fun_return, _apps} =
      Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))

    # TODO what is the result??
    Ecto.Migrator.with_repo(
      repo,
      fn r ->
        Triplex.all(r) |> Enum.map(&Ecto.Migrator.run(r, :down, to: version, prefix: &1.prefix))
      end
    )
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
