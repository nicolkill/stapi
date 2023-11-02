defmodule Mix.Tasks.Stapi.Generate do
  @moduledoc """
  This task generates an static api
  """
  use Mix.Task

  alias Stapi.FileCreator

  @chunk_folders ["page", "data"]

  defp path(steps), do: Enum.join(steps, "/")

  defp process_object(schema_name, object, output) do
    file_path = path([output, schema_name, "data", "#{object.id}.json"])
    encoded_object = Jason.encode!(object)
    FileCreator.clean_and_save(encoded_object, file_path)
    encoded_object
  end

  defp process_chunk(schema_name, {chunk, chunk_index}, output) do
    Enum.map(@chunk_folders, fn folder ->
      [output, schema_name, folder]
      |> path()
      |> FileCreator.create_folder()
    end)

    file_path = path([output, schema_name, "page", "#{chunk_index}.json"])

    FileCreator.clean_and_save("", file_path)

    chunk
    |> Enum.with_index()
    |> Enum.map(fn {object, index} ->
      encoded_object = process_object(schema_name, object, output)
      endline = if index < length(chunk) - 1, do: ",\n", else: ""
      content = "#{encoded_object}#{endline}"
      FileCreator.append(content, file_path)
    end)

  end

  defp process_ecto_schema(repo, page_size, ecto_schema, output) do
    schema_name = apply(ecto_schema, :__schema__, [:source])

    [output, schema_name]
    |> path()
    |> FileCreator.create_folder()

    stream =
      apply(repo, :stream, [ecto_schema])
      |> Stream.chunk_every(page_size)
      |> Stream.with_index()
      |> Stream.map(&process_chunk(schema_name, &1, output))

    func = fn ->
      Stream.run(stream)
    end

    apply(repo, :transaction, [func])
  end

  @impl Mix.Task
  def run([stapi_module]) do
    Mix.Task.run("app.start")

    stapi_module =
      ["Elixir", stapi_module]
      |> Enum.join(".")
      |> String.to_existing_atom()

    repo = apply(stapi_module, :repo, [])
    page_size = apply(stapi_module, :page_size, [])
    output = apply(stapi_module, :output, [])
    resources = apply(stapi_module, :resources, [])

    FileCreator.delete_folder(output)
    FileCreator.create_folder(output)

    Enum.map(resources, &process_ecto_schema(repo, page_size, &1, output))
  end

end