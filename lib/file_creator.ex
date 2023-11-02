defmodule Stapi.FileCreator do

  def append(content, file_path) do
    :ok = File.write(file_path, content, [:append])
  end

  def clean_and_save(content, file_path) do
    :ok = File.write(file_path, content)
  end

  def create_folder(folder_path) do
    case File.mkdir(folder_path) do
      :ok ->
        :ok
      {:error, :eexist} ->
        :ok
      _ ->
        raise "error with the folder"
    end
  end

  def delete_folder(folder_path) do
    case File.rm_rf(folder_path) do
      {:ok, files} when is_list(files) ->
        :ok
      _ ->
        raise "error deleting folder"
    end
  end
end