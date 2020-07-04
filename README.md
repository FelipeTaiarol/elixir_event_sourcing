# Event Sourcing in Elixir
Mostly just a pet project that I am creating to learn Elixir. **Still a work in progress**.

## Setup Instructions
You need a Postgres database running on **localhost:5432** which has a user with username **postgres** and password **postgres**.

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

## Entities
An Entity is a struct that must have at least these fields **id**, **type**, **version**. The **version** will be the number of **events** that were persisted to the event log of that Entity. To obtain the current state of the Entity we run all the events through the **apply_event/3** function (see below). 

## The Entity macro

### Creating a new Entity 
The [ShoppingListEntity](https://github.com/FelipeTaiarol/elixir_event_sourcing/blob/master/lib/example/shopping_list/shopping_list.entity.ex) is an example of usage of the Entity macro.

```elixir
defmodule Example.ShoppingListEntity do
  use Entities.Entity
```

To use the Entity macro you have to implement the following callbacks:

**get_entity_type() :: String.t()**.  
It should return an arbritary string that will be added to the ```entity_type``` column in the ```entities```, ```entity_actions``` and ```entity_events``` tables.
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
It receives the state of the Entity before the event, the event and the state of the Entity after the event. This callback will be executed only once when the event is being persisted.  
This callback gives you the opportunity to persist the change described by the event to the database in the same database transaction that persists the action and the events. 
You can use that to create an internal read model that is always consistent. This allows you to leverage database constraints to ensure cross entity business rules are obeyed.  
For example: If you want to make sure the shopping list names are unique, you can just have a **shopping_lists** table with a unique index in the **name** column and update that table in this callback.   
A more traditional approach is to have a separate process reading from the event log and projecting the events to a read model and creating compensanting transactions if something goes wrong.  
This is the only option you have if your event log is persisted to Kafka or something similar. Givan that we are persisting the events to Postgres there is no reason to not take advantage of the fact that we can have a read model that is always consistent and not only eventually consistent.  
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

**handle_create(context :: any, id :: integer, args :: any) :: any**.  

It receives the Entity ID and arguments and it should return an action. This action will be later sent to **handle_action**. The **args** parameters is the same that was passed to the **create** function (see below). The **id** will be generated when the **create** function is called.  

### Entity API

This is the public API of every Entity:

**def create(context, args)**. 

It receives the request context and arguments and it creates an instance of that Entity.

ps: **context** has always a hardcoded value for now. It will have information such as the userId and the requestId in the future.  

**def get(entity, context) when is_pid(entity)**.  

It receives the pid of the process for a given Entity instance, the request context and it returns the Entity.  

**def send_action(entity, context, action) when is_pid(entity)**

It receives the pid of the process for a given Entity instance, the request context and an action and it returns the changed Entity.  

### Finding the process for an Entity

To find the process for a given Entity instance you should use the **entity_process/3** function from the **Entities.Supervisor** module.  

```elixir
pid = Entities.Supervisor.entity_process(
    Example.ShoppingListEntity,
    shopping_list_id,
    context
  )
```

Check the [resolvers](https://github.com/FelipeTaiarol/elixir_event_sourcing/blob/master/lib/example_web/resolver.ex) for an example of usage of the Supervisor and the Entity API.  

### Entity Guarantees
  - Every Entity instance will be its own process. That guarantees that the calls to **send_action/3** will be serialized and executed one after the other.  
  - When the Entity process is created, the Entity will be loaded to the memory. That is done by getting all the events for that Entity and running the **apply_event/3** callback. Subsequent calls to **get/3** will be served data from the cache.  
  - The Entity will remain in memory until there is no read or write operation for more than 60 seconds. At that point the process will stop itself and the memory will be released. Before doing that, if the entity was changed, the current state of the Entity will be persisted for the **snapshot** colum of the **entities** table, the next time the entity is loaded the snapshot will be used as the starting point.   
  - Every time an action, and the events generated by it, are persisted to the database, we make sure that the version of the Entity in the database is the one we have in memory.  

### Entities Database Schema 

The **entities** table will have one row per Entity, it has the information about what is the current **version** of that Entity, i.e. the number of events that were persisted for that Entity.  

```elixir
  create table(:entities, prefix: "entities") do
    add(:version, :bigint, null: false)
    add(:type, :string, null: false)
    timestamps()
  end
```

The **entity_events** has one row per event. The **entity_version** column is the **version** the Entity was when that event was persisted.  

```elixir
  create table(:entity_events, prefix: "entities") do
    add(:entity_id, references(:entities), null: false)
    add(:entity_type, :string, null: false)
    add(:entity_version, :bigint, null: false)
    add(:type, :string, null: false)
    add(:payload, :map, null: false)
    add(:created_by, :bigint, null: false)
    add(:action_id, references(:entity_actions), null: false)
    timestamps()
  end

  create(unique_index(:entity_events, [:entity_id, :entity_version], prefix: "entities"))
```

The **entity_actions** table is used only for debugging. It is often useful to know what was the action that generated a given event.  
```elixir
    create table(:entity_actions, prefix: "entities") do
      add(:entity_id, references(:entities), null: false)
      add(:entity_type, :string, null: false)
      add(:type, :string, null: false)
      add(:payload, :map, null: false)
      add(:created_by, :bigint, null: false)
      timestamps()
    end
```


## Future Work
  1. Create an abstraction to have separate read models that are eventually consistent.  
  2. Create an implementation of the Saga pattern for long running operations.  
  3. Create a way to persist actions to multiple entities in the same database transaction (I have done that in a previous project and it is very useful if used with caution). 
  4. Create a way to allow a client to subscribe to changes of a given entity.
