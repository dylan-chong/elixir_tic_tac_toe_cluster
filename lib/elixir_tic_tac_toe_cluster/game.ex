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

    [player_x_node, player_o_node] =
      args
      |> Keyword.fetch!(:player_nodes)
      |> Enum.shuffle()

    {
      :ok,
      %GameState{
        o: %Player{node: player_o_node},
        x: %Player{node: player_x_node},
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

    game_state
    |> validate_turn(player_node, token, x, y)
    |> case do
      {:user_error, display_user_error, game_state} ->
        {:reply, {:user_error, display_user_error}, game_state}

      :ok ->
        new_state =
          game_state
          |> GameState.place_token(x, y, token)
          |> GameState.next_turn()

        if GameState.finished?(new_state) do
          GameView.display_winner_loser(new_state)
        else
          GameView.display_turn_applied(new_state)
          GameView.display_turn_messages(new_state)
        end

        {:reply, :ok, new_state}
    end
  end

  # Internal helper functions

  defp validate_turn(game_state, _player_node, player_token, x, y) do
    cond do
      GameState.finished?(game_state) ->
        display_user_error = fn ->
          GameView.display_user_error(Messages.game_already_finished())
        end

        {:user_error, display_user_error, game_state}

      player_token != game_state.turn ->
        display_user_error = fn ->
          GameView.display_user_error(Messages.not_your_turn())
        end

        {:user_error, display_user_error, game_state}

      game_state.board |> Enum.at(y) |> Enum.at(x) != :_ ->
        display_user_error = fn ->
          player_token
          |> Messages.non_empty_square_played(x, y)
          |> GameView.display_user_error()
        end

        {:user_error, display_user_error, game_state}

      true ->
        :ok
    end
  end
end
