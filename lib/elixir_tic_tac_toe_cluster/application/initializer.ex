defmodule ElixirTicTacToeCluster.Application.Initializer do
  require Logger

  alias ElixirTicTacToeCluster.{
    ClusterAutoConnector,
    GameAssignment,
    Messages,
    Game
  }

  def initialize() do
    ClusterAutoConnector.auto_connect()
    try_start_game_with_another_node()

    :ok
  end

  defp try_start_game_with_another_node() do
    Node.list()
    |> Stream.map(&try_start_game_with/1)
    |> Enum.find(false, & &1)
    |> unless do
      Messages.display_waiting_for_players()
    end
  end

  defp try_start_game_with(node) do
    node
    |> GameAssignment.assign_new_opponent_to_self()
    |> if do
      GameAssignment.assign_own_opponent(node)
      Logger.debug("Starting a new game with #{node}")
      {:ok, game} = start_game_with(node)
      GameAssignment.set_current_game_pid(node, game)
      GameAssignment.set_current_game_pid(Node.self(), game)
      true
    else
      Logger.debug("Node #{node} is already in a game")
      false
    end
  end

  defp start_game_with(node) do
    supervisor = ElixirTicTacToeCluster.GamesSupervisor

    player_nodes = [node, Node.self()]

    {:ok, game} = DynamicSupervisor.start_child(supervisor, {Game, player_nodes: player_nodes})
    game |> Game.begin()

    {:ok, game}
  end
end
