ExUnit.start()
:ok = Ecto.Adapters.SQL.Sandbox.checkout(Voomex.Repo)
# Marking the DB connection as shared means other processes (such as Oban) can use it,
# but means that we cannot use async tests. There are workaround if we want to change
# that https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.Sandbox.html#module-allowances
Ecto.Adapters.SQL.Sandbox.mode(Voomex.Repo, {:shared, self()})
