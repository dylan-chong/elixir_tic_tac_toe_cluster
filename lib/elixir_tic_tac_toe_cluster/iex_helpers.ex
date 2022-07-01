defmodule ElixirTicTacToeCluster.IExHelpers do
  @moduledoc """
  Functions are imported into iex shell for convenience
  """

  def states() do
    ElixirTicTacToeCluster.Supervisor
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {module, _, _, _} -> module end)
    |> Map.new(&{&1, state(&1)})
  end

  def state(gen_server_name) do
    gen_server_name
    |> Process.whereis()
    |> :sys.get_state()
  end
end
