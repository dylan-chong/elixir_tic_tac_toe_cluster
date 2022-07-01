defmodule ElixirTicTacToeCluster.GameAssignment do
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

  def set_current_game_pid(node, game_pid) do
    :ok_set = {@name, node} |> GenServer.call({:set_current_game_pid, %{game_pid: game_pid}})
  end

  def fetch_current_game_pid!() do
    @name |> GenServer.call(:fetch_current_game_pid!)
  end

  # Internal functions

  defmodule AssignmentState do
    @enforce_keys [:opponent_node, :game_pid]
    defstruct @enforce_keys
  end

  @impl true
  def init(:unused_value) do
    {:ok, %AssignmentState{opponent_node: :not_assigned, game_pid: :not_assigned}}
  end

  @impl true
  def handle_call(
        {:assign_new_opponent, %{with_node: new_opponent}},
        _from,
        state = %AssignmentState{opponent_node: :not_assigned}
      ) do
    {:reply, :ok_assigned, %{state | opponent_node: new_opponent}}
  end

  def handle_call(
        {:assign_new_opponent, %{with_node: _with_node}},
        _from,
        state = %AssignmentState{opponent_node: _opponent_node}
      ) do
    {:reply, :already_assigned, state}
  end

  def handle_call(
        {:set_current_game_pid, %{game_pid: game_pid}},
        _from,
        state = %AssignmentState{opponent_node: opponent_node, game_pid: :not_assigned}
      )
      when opponent_node != :not_assigned do
    {:reply, :ok_set, %AssignmentState{state | game_pid: game_pid}}
  end

  def handle_call(:fetch_current_game_pid!, _from, state = %AssignmentState{game_pid: game_pid})
      when game_pid != :not_assigned do
    {:reply, game_pid, state}
  end
end
