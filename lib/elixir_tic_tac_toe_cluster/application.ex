defmodule ElixirTicTacToeCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias ElixirTicTacToeCluster.ClusterAutoConnector

  @impl true
  def start(_type, _args) do


    children = [
      # Starts a worker by calling: ElixirTicTacToeCluster.Worker.start_link(arg)
      # {ElixirTicTacToeCluster.Worker, arg}
      {Task, &ClusterAutoConnector.auto_connect/0}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirTicTacToeCluster.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
