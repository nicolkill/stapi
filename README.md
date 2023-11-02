## Stapi

Stapi comes from `Static API` that helps to generate static files API using a list of ecto schemas from your database and
the data it's the moment data snapshot of the schemas.



## Installation

If [available in Hex](https://hex.pm/packages/stapi), the package can be installed
by adding `stapi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:stapi, "~> 0.1.0"}
  ]
end
```

## Usage

#### The module

To use you need create one module that uses the module `Stapi` and configure the ecto repo an ecto schemas

```elixir
defmodule YourApplication.StaticApi do
  use Stapi,
    repo: YourApplication.Repo,  # MANDATORY!
    page_size: 100,              # default: 100
    output: "some_folder",       # default: "generated"
    resources: [
      YourApplication.Products.Product
    ]
end
```

#### The task

To generate the API you need run

```
mix stapi.generate YourApplication.StaticApi
```

And this will generate folder `generated` (or the specified in the module)

#### The structure

```
:schema/page/:page
:schema/data/:id
```
