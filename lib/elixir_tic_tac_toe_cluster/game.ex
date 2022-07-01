defmodule ElixirTicTacToeCluster.Game do
  @moduledoc """
  The game's model
  """
  use GenServer
  alias ElixirTicTacToeCluster.GameView
  alias ElixirTicTacToeCluster.Game.{GameState, Player}
  alias ElixirTicTacToeCluster.Messages

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def begin(game) do
    game |> GenServer.call(:begin)
  end

  def play_turn(game, player_node, x, y) do
    game
    |> GenServer.call({:play_turn, %{player_node: player_node, x: x, y: y}})
    |> case do
      :ok ->
        :ok

      {:user_error, display_error} ->
        display_error.()
        :user_error
    end
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
  def handle_call(:begin, _from, game_state) do
    GameView.display_starting_messages(game_state)
    GameView.display_turn_messages(game_state)
    {:reply, :ok, game_state}
  end

  def handle_call({:play_turn, %{player_node: player_node, x: x, y: y}}, _from, game_state) do
    {_player, token} = GameState.player_for_node(game_state, player_node)

    cond do
      token != game_state.turn ->
        display_user_error = fn ->
          GameView.display_user_error(game_state, Messages.not_your_turn(), users_turn?: false)
        end

        {:reply, {:user_error, display_user_error}, game_state}

      game_state.board |> Enum.at(y) |> Enum.at(x) != :_ ->
        display_user_error = fn ->
          GameView.display_user_error(game_state, Messages.non_empty_square_played(token, x, y),
            users_turn?: true
          )
        end

        {:reply, {:user_error, display_user_error}, game_state}

      true ->
        new_state =
          game_state
          |> GameState.next_turn()
          |> GameState.place_token(x, y)

        GameView.display_turn_applied(new_state, new_state.board)
        GameView.display_turn_messages(new_state)
        {:reply, :ok, new_state}
    end
  end

  # Internal helper functions
end
