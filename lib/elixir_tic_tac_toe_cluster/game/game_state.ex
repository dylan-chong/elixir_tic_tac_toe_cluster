defmodule ElixirTicTacToeCluster.Game.GameState do
  @moduledoc """
  - :o - player o
  - :x - player x
  - :turn - :o or :x
  - :board - 2d list of :o or :x or :_
  """
  @enforce_keys ~w[o x turn board]a
  defstruct @enforce_keys

  def opponent_for_node(game_state, node) do
    game_state
    |> players()
    |> Enum.filter()
  end

  defp players(game_state), do: Map.take(game_state, [:o, :x])
end
