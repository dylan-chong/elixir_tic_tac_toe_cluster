defmodule ElixirTicTacToeCluster.Game.Player do
  @enforce_keys ~w[node]a
  defstruct @enforce_keys

  def opponent(:x), do: :o
  def opponent(:o), do: :x
end
