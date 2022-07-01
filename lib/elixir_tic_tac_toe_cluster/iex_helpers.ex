defmodule ElixirTicTacToeCluster.IExHelpers do
  @moduledoc """
  Functions are imported into iex shell for convenience
  """

  require Logger

  def possible_names do
    "abcdefghijklmnopqrstuvwxyz"
    |> String.graphemes()
    |> Enum.map(&String.to_atom/1)
  end

  def auto_connect() do
    connect_any([:a, :b, :c, :d])
    {:connected_nodes, Node.list()}
  end

  def connect_any(names) do
    names |> Enum.map(&connect_to/1)
  end

  def connect_to(name) do
    node_atom = full_node_atom(name)

    if node_atom == node() do
      false
    else
      node_atom
      |> Node.connect()
      |> tap(fn connected? ->
        Logger.info("Connected to node #{node_atom}")
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
