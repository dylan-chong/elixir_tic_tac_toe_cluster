defmodule ElixirTicTacToeCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  alias ElixirTicTacToeCluster.ClusterAutoConnector
  alias ElixirTicTacToeCluster.GameAssignmentState
  alias ElixirTicTacToeCluster.Game
  alias ElixirTicTacToeCluster.GameView

  @impl true
  def start(_type, _args) do
    children = [
      # Singletons
      GameAssignmentState,
      GameView,
      # Games
      {DynamicSupervisor, name: ElixirTicTacToeCluster.GamesSupervisor, strategy: :one_for_one},
      # Other
      {Task, &initialize_app/0}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirTicTacToeCluster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp initialize_app() do
    ClusterAutoConnector.auto_connect()
    try_start_game_with_another_node()

    :ok
  end

  defp try_start_game_with_another_node() do
    Node.list()
    |> Stream.map(&try_start_game_with/1)
    |> Enum.find(false, & &1)
  end

  defp try_start_game_with(node) do
    node
    |> GameAssignmentState.assign_new_opponent_to_self()
    |> if do
      GameAssignmentState.assign_own_opponent(node)
      Logger.info("Starting a new game with #{node}")
      start_game_with(node)
      true
    else
      Logger.info("Waiting for players")
      false
    end
  end

  defp start_game_with(node) do
    supervisor = ElixirTicTacToeCluster.GamesSupervisor

    player_views = [
      {GameView.name(), node},
      {GameView.name(), Node.self()}
    ]

    {:ok, game} = DynamicSupervisor.start_child(supervisor, {Game, player_views: player_views})
    game |> Game.begin()

    :ok
  end
end
