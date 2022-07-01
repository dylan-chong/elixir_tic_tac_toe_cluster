defmodule ElixirTicTacToeCluster.ClusterAutoConnector do
  require Logger

  def auto_connect() do
    connect_any(possible_names())
    {:connected_nodes, Node.list()}
  end

  def possible_names do
    "abcdefghijklmnopqrstuvwxyz"
    |> String.graphemes()
    |> Enum.map(&String.to_atom/1)
  end

  def connect_any(names) do
    # Stops once it has connected to one node
    names |> Enum.find(false, &connect_to/1)
  end

  def connect_to(name) do
    node_atom = full_node_atom(name)

    if node_atom == node() do
      false
    else
      node_atom
      |> Node.connect()
      |> tap(fn connected? ->
        if connected?, do: Logger.info("Connected to node #{node_atom}")
      end)
    end
  end

  def full_node_atom(name) do
    node()
    |> Atom.to_string()
    |> String.replace(~r/^[^@]+/, Atom.to_string(name))
    |> String.to_atom()
  end
end
