defmodule Stapi do
  @moduledoc """
  Stapi comes from `Static API` that helps to generate static files API using a list of ecto schemas from your database and
  the data it's the moment data snapshot of the schemas.

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
  """

  @key_repo {:repo, nil}
  @key_resources {:resources, []}
  @key_page_size {:page_size, 100}
  @key_output {:output, "generated"}

  @keys [@key_repo, @key_resources, @key_page_size, @key_output]
  @mandatory_keys [@key_repo]

  defmacro __using__(opts) do
    attrs =
      Enum.map(
        @keys,
        &({elem(&1, 0), Keyword.get(opts, elem(&1, 0), elem(&1, 1))})
      )

    missing_mandatory_keys =
      Enum.filter(@mandatory_keys, &is_nil(Keyword.get(attrs, elem(&1, 0))))
    if length(missing_mandatory_keys) > 0 do
      keys =
        missing_mandatory_keys
        |> Enum.map(&(":#{elem(&1, 0)}"))
        |> Enum.join(", ")

      raise "#{keys} must be defined"
    end

    [repo, resources, page_size, output] =
      Enum.map(attrs, &elem(&1, 1))

    quote do
      def repo, do: unquote(repo)
      def resources, do: unquote(resources)
      def page_size, do: unquote(page_size)
      def output, do: unquote(output)
    end
  end
end
