defmodule ElixirTicTacToeCluster.Game.GameState do
  @moduledoc """
  - :o - player o
  - :x - player x
  - :turn - :o or :x
  - :board - 2d list of :o or :x or :_
  """
  @enforce_keys ~w[o x turn board]a
  defstruct @enforce_keys

  alias ElixirTicTacToeCluster.Game.Player

  def player_for_node(%__MODULE__{o: player = %Player{node: node}}, node) do
    {player, :o}
  end

  def player_for_node(%__MODULE__{x: player = %Player{node: node}}, node) do
    {player, :x}
  end

  def next_turn(game_state = %__MODULE__{turn: turn}) do
    %__MODULE__{game_state | turn: Player.opponent(turn)}
  end

  @doc """
  Assumes x and y have been validated
  """
  def place_token(game_state = %__MODULE__{}, x, y) do
    game_state
    |> put_in(
      [Access.key!(:board), Access.at(y), Access.at(x)],
      game_state.turn
    )
  end
end
