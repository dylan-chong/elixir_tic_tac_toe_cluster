defmodule ElixirTicTacToeCluster.ClusterAutoConnector do
  require Logger

  def auto_connect() do
    connect_all(possible_names())
    {:connected_nodes, Node.list()}
  end

  def possible_names do
    "abcdefghijklmnopqrstuvwxyz"
    |> String.graphemes()
    |> Enum.map(&String.to_atom/1)
  end

  def connect_all(_names = []) do
    Logger.debug("Did not connect to any nodes")
  end

  def connect_all(names) do
    names
    |> Enum.map(&connect_to/1)
    |> Enum.all?()
    |> tap(fn connected? ->
      if !connected?, do: Logger.debug("Did not connect to any nodes")
    end)
  end

  def connect_to(name) do
    node_atom = name_plus_host(name)

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

  def name_plus_host(name) do
    node()
    |> Atom.to_string()
    |> String.replace(~r/^[^@]+/, Atom.to_string(name))
    |> String.to_atom()
  end
end
