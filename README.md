# ElixirTicTacToeCluster

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elixir_tic_tac_toe_cluster` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixir_tic_tac_toe_cluster, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/elixir_tic_tac_toe_cluster>.

## Running

Start one or mode nodes, passing a name that is a single lowercase letter. This
will allow automagic connection to the cluster (details in
`ElixirTicTacToeCluster.ClusterAutoConnector`).

```
shell_a> iex --cookie cookie --name a -S mix run

shell_b> iex --cookie cookie --name b -S mix run
```

## Debugging

See `.iex.exs`
