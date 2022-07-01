defmodule ElixirTicTacToeCluster.IExHelpers do
  @moduledoc """
  Functions are imported into iex shell for convenience
  """

  alias ElixirTicTacToeCluster.Application
  alias ElixirTicTacToeCluster.Messages

  @doc """
  """
  def play(x, y) when x in 0..2 and y in 0..2 do
    Application.play_turn_from_current_node(x, y)
    :ok
  end

  def play(x, y) do
    Messages.display_invalid_turn(x, y)
  end

  @doc """
  Debugging function that gives the state of all the important process on this node
  """
  def states() do
    game_pids =
      ElixirTicTacToeCluster.GamesSupervisor
      |> DynamicSupervisor.which_children()
      |> Enum.map(fn {module, _, _, _} -> module end)

    game_pids
    |> Map.new(&{"Game #{inspect(&1)}", state(&1)})
    |> Map.merge(%{
      ElixirTicTacToeCluster.GameAssignment => state(ElixirTicTacToeCluster.GameAssignment),
      ElixirTicTacToeCluster.GameView => state(ElixirTicTacToeCluster.GameView)
    })
  end

  def state(gen_server) when not is_pid(gen_server) do
    gen_server
    |> Process.whereis()
    |> state()
  end

  def state(gen_server_name) do
    gen_server_name
    |> :sys.get_state()
  end
end
