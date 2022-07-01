defmodule ElixirTicTacToeCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  alias ElixirTicTacToeCluster.ClusterAutoConnector
  alias ElixirTicTacToeCluster.GameAssignmentState
  alias ElixirTicTacToeCluster.Game

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirTicTacToeCluster.Supervisor]

    with {:ok, supervisor} <- DynamicSupervisor.start_link(opts),
         {:ok, _} <- DynamicSupervisor.start_child(supervisor, GameAssignmentState),
         {:ok, _} <- DynamicSupervisor.start_child(supervisor, {Task, &initialize_app/0}) do
      {:ok, supervisor}
    end
  end

  defp initialize_app() do
    ClusterAutoConnector.auto_connect()
    try_start_game_with_another_node()
    :ok
  end

  defp try_start_game_with_another_node() do
    Node.list()
    |> Stream.map(&try_start_game/1)
    |> Enum.find(false, & &1)
  end

  defp try_start_game(node) do
    node
    |> GameAssignmentState.assign_new_opponent()
    |> if do
      Logger.info("Starting a new game with #{node}")
      true
    else
      false
    end
  end
end
