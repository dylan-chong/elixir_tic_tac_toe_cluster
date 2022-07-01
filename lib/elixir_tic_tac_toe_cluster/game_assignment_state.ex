defmodule ElixirTicTacToeCluster.GameAssignmentState do
  use GenServer

  @name __MODULE__

  def start_link([]) do
    GenServer.start_link(__MODULE__, :unused_value, name: @name)
  end

  def assign_new_opponent_to_self(opponent_node) do
    me = Node.self()

    {@name, opponent_node}
    |> GenServer.call({:assign_new_opponent, %{with_node: me}})
    |> case do
      :already_assigned -> false
      :ok_assigned -> true
    end
  end

  def assign_own_opponent(opponent_node) do
    :ok_assigned = @name |> GenServer.call({:assign_new_opponent, %{with_node: opponent_node}})

    true
  end

  # Internal functions

  @initial_state %{opponent_node: :not_assigned}

  @impl true
  def init(:unused_value) do
    {:ok, @initial_state}
  end

  @impl true
  def handle_call(
        {:assign_new_opponent, %{with_node: new_opponent}},
        _from,
        state = %{opponent_node: :not_assigned}
      ) do
    {:reply, :ok_assigned, %{state | opponent_node: new_opponent}}
  end

  def handle_call(
        {:assign_new_opponent, %{with_node: _with_node}},
        _from,
        state = %{opponent_node: _opponent_node}
      ) do
    {:reply, :already_assigned, state}
  end
end
