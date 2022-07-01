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

  @name __MODULE__

  def name, do: @name

  def start_link([]) do
    GenServer.start_link(__MODULE__, :unused_value, name: @name)
  end

  def display_starting_messages(game_state) do
    game_state.o.game_view
    |> display(:started_game, you: :o, opponent_node: game_state.x.game_view |> elem(1))

    game_state.x.game_view
    |> display(:started_game, you: :x, opponent_node: game_state.o.game_view |> elem(1))
  end

  def display_turn_message(game_state) do
    game_state
    |> Map.fetch!(game_state.turn)
    |> Map.fetch!(:game_view)
    |> display(:its_your_turn)
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
    |> message_to_display(args |> Map.new())
    # Prints message to local node's console
    |> IO.puts()

    {:reply, :ok, :unused_state}
  end

  defp message_to_display(:started_game, %{you: you, opponent_node: opponent_node}) do
    """
    \nStarted game with #{opponent_node}
    You are #{you}
    """
  end

  defp message_to_display(:its_your_turn, %{}) do
    "It's your turn!"
  end
end
