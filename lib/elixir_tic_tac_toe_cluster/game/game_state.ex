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
  def place_token(game_state = %__MODULE__{turn: token}, x, y, token) do
    game_state
    |> put_in(
      [Access.key!(:board), Access.at(y), Access.at(x)],
      game_state.turn
    )
  end

  def finished?(game_state), do: winner(game_state) != nil

  def winner(game_state) do
    [
      game_state.board |> rows(),
      game_state.board |> columns(),
      game_state.board |> diagonals()
    ]
    |> Stream.concat()
    |> Stream.map(&winner_token_for_line/1)
    |> Stream.filter(&(&1 != nil))
    |> Enum.uniq()
    |> case do
      [] -> nil
      [winner_token] -> {game_state |> Map.fetch!(winner_token), winner_token}
    end
  end

  def loser(game_state) do
    case winner(game_state) do
      nil ->
        nil

      {_winner, winner_token} ->
        loser_token = Player.opponent(winner_token)
        {game_state |> Map.fetch!(loser_token), loser_token}
    end
  end

  defp winner_token_for_line(line_of_tokens) do
    line_of_tokens
    |> Enum.uniq()
    |> case do
      multiple_tokens when length(multiple_tokens) > 1 -> nil
      [:_] -> nil
      [winner] when winner in [:o, :x] -> winner
    end
  end

  defp rows(board), do: board

  defp columns(board) do
    Enum.map(0..2, fn x ->
      Enum.map(0..2, fn y ->
        at(board, x, y)
      end)
    end)
  end

  defp diagonals(board) do
    [
      [at(board, 0, 0), at(board, 2, 2), at(board, 2, 2)],
      [at(board, 2, 0), at(board, 1, 2), at(board, 0, 2)]
    ]
  end

  defp at(board, x, y), do: get_in(board, [Access.at(y), Access.at(x)])
end
