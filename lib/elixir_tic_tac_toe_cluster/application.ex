defmodule ElixirTicTacToeCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ElixirTicTacToeCluster.{
    Application.Initializer,
    GameAssignment,
    Game,
    GameView
  }

  @impl true
  def start(_type, _args) do
    children = [
      # Singletons
      GameAssignment,
      GameView,
      # Games
      {DynamicSupervisor, name: ElixirTicTacToeCluster.GamesSupervisor, strategy: :one_for_one},
      # Other
      {Task, &Initializer.initialize/0}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirTicTacToeCluster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def play_turn_from_current_node(x, y) do
    player_node = Node.self()
    game = GameAssignment.fetch_current_game_pid!()

    game |> Game.play_turn(player_node, x, y)
  end
end
