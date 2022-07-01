defmodule ElixirTicTacToeCluster.Game do
  @moduledoc """
  The game's model
  """
  use GenServer
  alias ElixirTicTacToeCluster.GameView

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def begin(game) do
    game |> GenServer.call(:begin)
  end

  # Internal GenServer functions

  defmodule Player do
    @enforce_keys ~w[game_view]a
    defstruct @enforce_keys
  end

  defmodule GameState do
    @enforce_keys ~w[o x turn]a
    defstruct @enforce_keys
  end

  @impl true
  def init(args) do
    args = Keyword.validate!(args, [:player_views])

    [player_x_view, player_o_view] =
      args
      |> Keyword.fetch!(:player_views)
      |> Enum.shuffle()

    {
      :ok,
      %GameState{
        o: %Player{game_view: player_o_view},
        x: %Player{game_view: player_x_view},
        turn: :o
      }
    }
  end

  @impl true
  def handle_call(:begin, _from, state) do
    GameView.display_starting_messages(state)
    GameView.display_turn_message(state)
    {:reply, :ok, state}
  end

  # Internal helper functions
end
