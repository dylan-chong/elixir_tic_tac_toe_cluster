defmodule ElixirTicTacToeCluster.MessageDisplayer do
  @doc """
  Prints message to local node's console
  """
  def display(string) do
    IO.puts(string)
  end

  def display_waiting_for_players do
    "Waiting for players"
    |> display()
  end

  def display_invalid_turn(x, y) do
    """
    Invalid call play(x, y) (x: #{inspect(x)}, y: #{inspect(y)})
    #{play_turn_instructions()}
    """
    |> display()
  end

  def play_turn_instructions do
    """
    Type `play(x, y)` to insert your token into an empty square
    - where: x is the col (0 as the left, 2 as the right)`
    - where: y is the row (0 as the top, 2 as the bottom)`
    """
  end
end
