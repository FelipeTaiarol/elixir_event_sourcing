# Event Sourcing in Elixir
Mostly just a pet project that I am creating to learn Elixir.


## Setup Instructions
You need a Postgres database running on **localhost:5432** which has a user with username **postgres** and password **postgres**.

Create two databases in your Postgres instance, one called **shopping_lists** and another called **shopping_lists_test**

Run ```mix ecto.setup``` to create the schemas.

Run ```mix phx.server``` to run the application.

Go to http://localhost:4000/graphiql and execute graphql queries.

## Folder Structure and Architecture
