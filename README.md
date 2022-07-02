# ElixirTicTacToeCluster

Multiplayer TTT serverless game.

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
