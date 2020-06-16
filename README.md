# Event Sourcing in Elixir
Mostly just a pet project that I am creating to learn Elixir.


## Setup Instructions
You need a Postgres database running on **localhost:5432** which has a user with username **postgres** and password **postgres**.

Create two databases in your Postgres instance, one called **shopping_lists** and another called **shopping_lists_test**

Run ```mix ecto.setup``` to create the schemas.

Run ```mix phx.server``` to run the application.

Go to http://localhost:4000/graphiql and execute graphql queries.

## Folder Structure
```
lib
├── entities     -> Code for the Event Sourcing library. The central component is the Entity macro.
├── example      -> Example usage of the Entity macro in the ShoppingList Entity.
└── example_web  -> Graphql that consumes the ShoppingList Entity.
```

## The Entity macro

The [ShoppingListEntity](https://github.com/FelipeTaiarol/elixir_event_sourcing/blob/master/lib/example/shopping_list/shopping_list.entity.ex) is an example of usage of the Entity macro.

```elixir
defmodule Example.ShoppingListEntity do
  use Entities.Entity
```

To use the Entity macro you have to implement the following callbacks:

**get_entity_type() :: String.t()**.  
It should return an arbritary string that will be added to the ```entity_type``` column in the ```entity_actions``` and ```entity_events``` tables.
```elixir
def get_entity_type(), do: "shopping_list"
```

**handle_action(context :: any, state :: any, action :: any) :: list(any)**.   
It receives the current state of the entity and an action and it should return a list of events.
This is where all the validation logic should be. This callback will be executed only once for each action that is received. 
```elixir
def handle_action(%Context{} = _context, %ShoppingListEntity{} = _state, %SetName{name: name}) do
  [%NameChanged{name: name}]
end
```

**apply_event(context :: any, state :: any, event :: any) :: any**.  
It receives the current state of the Entity and an Event and it should return the changed Entity state.
This should have only straight forward transformation from the old to the new state. This callback will be executed every time the Entity is loaded into memory. 
```elixir
def apply_event(%Context{} = _context, %ShoppingListEntity{} = state, %NameChanged{name: name}) do
  %ShoppingListEntity{state | name: name}
end
```

**project_event(context :: any, before_event :: any, event :: any, before_event :: any) :: any**.  
It receives the state of the Entity before the event, the Event and the state of the Entity after the Event. It can project that event to a data store.  
This callback gives you the opportunity to persist the change described by the event to the database in the same database transaction that persists the action and the events.  
You can use that to create an internal read model that is always consistent. This allows you to leverage database constraints to ensure cross entity business rules are obeyed.   
For example: If you want to make sure the shopping list names are unique you can just have a **shopping_lists** table with a unique index in the **name** column and update that table in this callback.   
A more traditional approach is to have a separate process reading from the event log and projecting the events to a read model. This is the only option you have if your event log is persisted to Kafka or something similar. Givan that we are persisting the events to Postgres there is no reason to not take advantage of the fact that we can have a read model that is always consistent and not only eventually consistent.  
```elixir
  def project_event(
        %Context{} = _context,
        %ShoppingListEntity{} = _before_event,
        %NameChanged{} = _event,
        %ShoppingListEntity{} = after_event
      ) do
        %Tables.ShoppingList{id: after_event.id}
          |> Tables.ShoppingList.changeset(%{id: after_event.id, name: after_event.name})
          |> Repo.update!()
  end
```


