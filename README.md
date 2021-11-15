# Sketch

Sketch is a GraphQL API to draw on a canva. 

The core functionalities of drawing on a canvas are implemented in [`canvas.ex`](lib/sketch/domain_models/canvas/canvas.ex).
The GraphQL schema, with its queries, mutations and subscriptions is to be found in [`schema.ex`](lib/sketch_web/graphql/schema/schema.ex).
You can talk to the server either with through the GraphiQL client (for reads and writes) or the browser (read-only). LiveView is used to avoid browser refreshes and update the web page with the new canvas/drawing in real-time.

To play around, follow those instructions:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  * Now you can visit [`localhost:4000/canvas`](http://localhost:4000/canvas) from your browser.
  * In a new window, visit the [GraphiQL endpoint](http://localhost:4000/api/raphiql).
  * Upload the [GraphIQL workspace](graphiql-workspace-2021-11-15-19-02-33.json).
  * You'll find three tabs with pre-made queries in each. Each sequence of queries in a tab corresponds to a test fixture. Give it a try!


## Running the tests:
```elixir
mix test --trace
```