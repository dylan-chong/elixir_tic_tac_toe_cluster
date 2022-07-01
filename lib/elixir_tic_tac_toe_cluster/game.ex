defmodule ElixirTicTacToeCluster.Game do
  @moduledoc """
  The game's model
  """
  use GenServer
  alias ElixirTicTacToeCluster.GameView
  alias ElixirTicTacToeCluster.Game.{GameState, Player}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def begin(game) do
    game |> GenServer.call(:begin)
  end

  def play_turn(game, player_node, x, y) do
    game |> GenServer.call({:play_turn, %{player_node: player_node, x: x, y: y}})
  end

  # Internal GenServer functions

  @impl true
  def init(args) do
    args = Keyword.validate!(args, [:player_nodes])

    [player_x_view, player_o_view] =
      args
      |> Keyword.fetch!(:player_nodes)
      |> Enum.shuffle()

    {
      :ok,
      %GameState{
        o: %Player{node: player_o_view},
        x: %Player{node: player_x_view},
        turn: :o,
        board: [
          [:_, :_, :_],
          [:_, :_, :_],
          [:_, :_, :_]
        ]
      }
    }
  end

  @impl true
  def handle_call(:begin, _from, state) do
    GameView.display_starting_messages(state)
    GameView.display_turn_message(state)
    {:reply, :ok, state}
  end

  def handle_call({:play_turn, %{player_node: player_node, x: x, y: y}}, _from, state) do
    # player_node
    {:reply, :ok, state}
  end

  # Internal helper functions
end
