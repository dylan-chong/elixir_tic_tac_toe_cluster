defmodule ElixirTicTacToeCluster.Messages do
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
    Invalid call play(x, y): `play(#{inspect(x)}, #{inspect(y)})`
    #{play_turn_instructions()}
    """
    |> String.replace(~r/\n+/, "\n")
    |> display()
  end

  def play_turn_instructions do
    """
    Type `play(x, y)` to insert your token into an empty square
    - where: x is the col (0 as the left, 2 as the right)`
    - where: y is the row (0 as the top, 2 as the bottom)`
    - where: the square is empty (`_`)
    - where: it is your turn
    """
  end

  def not_your_turn do
    "It's not your turn to play!"
  end

  def non_empty_square_played(player_token, x, y) do
    "Cannot place token #{player_token} at given position (x: #{x}, y: #{y}) is not empty"
  end
end
