defmodule ElixirTicTacToeCluster.GameView do
  @moduledoc """
  The game's visual reporting. This is on both players' nodes to decouple the node running the
  `Game` and the `Game` itself, and so both the node running the game and the other node can be
  treated more equally by the `Game`.

  This also allows the `Game` to link to processes on both nodes so can die if one machine
  disconnects.

  This is basically an observer. TODO replace with GenEvent
  """

  use GenServer
  alias ElixirTicTacToeCluster.Game.Player
  alias ElixirTicTacToeCluster.Game.GameState
  alias ElixirTicTacToeCluster.Messages

  @name __MODULE__

  def name_for_node(node), do: {@name, node}

  def start_link([]) do
    GenServer.start_link(__MODULE__, :unused_value, name: @name)
  end

  def display_starting_messages(game_state) do
    game_state.o.node
    |> name_for_node()
    |> display(:started_game, you: :o, opponent_node: game_state.x.node)

    game_state.x.node
    |> name_for_node()
    |> display(:started_game, you: :x, opponent_node: game_state.o.node)
  end

  def display_turn_messages(game_state) do
    display_its_your_turn(game_state)
    display_waiting_for_turn(game_state)
  end

  def display_its_your_turn(game_state) do
    game_state
    |> Map.fetch!(game_state.turn)
    |> Map.fetch!(:node)
    |> name_for_node()
    |> display(:its_your_turn, board: game_state.board)
  end

  def display_waiting_for_turn(game_state) do
    game_state
    |> Map.fetch!(game_state.turn |> Player.opponent())
    |> Map.fetch!(:node)
    |> name_for_node()
    |> display(:awaiting_turn)
  end

  def display_user_error(user_error) do
    Messages.display("Error: " <> user_error)
  end

  def display_turn_applied(game_state) do
    game_state
    # Want to alert the player that just played
    |> Map.fetch!(game_state.turn |> Player.opponent())
    |> Map.fetch!(:node)
    |> name_for_node()
    |> display(:turn_applied, board: game_state.board)
  end

  def display_winner_loser(game_state) do
    game_state
    |> GameState.winner()
    |> elem(0)
    |> Map.fetch!(:node)
    |> name_for_node()
    |> display(:you_won, board: game_state.board)

    game_state
    |> GameState.loser()
    |> elem(0)
    |> Map.fetch!(:node)
    |> name_for_node()
    |> display(:you_lost, board: game_state.board)
  end

  defp display(game_view, type, args \\ []) do
    game_view |> GenServer.call({:display, type, args |> Map.new()})
  end

  # Internal functions

  @initial_state :unused_state

  @impl true
  def init(:unused_value) do
    {:ok, @initial_state}
  end

  @impl true
  def handle_call({:display, type, args}, _from, :unused_state) do
    type
    |> message_string(args |> Map.new())
    |> Messages.display()

    {:reply, :ok, :unused_state}
  end

  defp message_string(:started_game, %{you: you, opponent_node: opponent_node}) do
    """
    \nStarted game with #{opponent_node}
    Your token is `#{you}`
    """
  end

  defp message_string(:its_your_turn, %{board: board}) do
    """
    It's your turn!

    #{render_board(board)}

    #{Messages.play_turn_instructions()}
    """
  end

  defp message_string(:awaiting_turn, %{}) do
    "Waiting for your turn"
  end

  defp message_string(:turn_applied, %{board: board}) do
    """
    Your turn has been applied

    #{render_board(board)}
    """
  end

  defp message_string(:you_won, %{board: board}) do
    """
    Your turn has been applied

    #{render_board(board)}

    You won! Congratulations!
    """
  end

  defp message_string(:you_lost, %{board: board}) do
    """
    Your opponent has done their move

    #{render_board(board)}

    You lost! Sorry!
    """
  end

  defp render_board(board) do
    rows_strings =
      board
      |> Enum.map(fn row ->
        row_string =
          row
          |> Enum.map(fn cell -> Atom.to_string(cell) end)
          |> Enum.join(" ")

        "| #{row_string} |"
      end)

    horizontal_line =
      rows_strings
      |> List.first()
      |> String.replace(~r/./, "-")

    [
      [horizontal_line],
      rows_strings,
      [horizontal_line]
    ]
    |> Enum.concat()
    |> Enum.join("\n")
    |> String.pad_leading(4)
  end
end
