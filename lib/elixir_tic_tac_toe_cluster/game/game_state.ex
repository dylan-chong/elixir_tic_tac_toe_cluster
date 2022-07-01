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

  def finished?(game_state), do: winner(game_state) != nil

  def winner(game_state) do
    # game_state.board
    # TODO
    if Enum.random(1..5) > 3 do
      {game_state.o, :o}
    else
      {game_state.o, :o}
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
end
