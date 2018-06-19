defmodule Tankinho.LiveReload do
  def watch_for_changes(directories, modules) do
    {:ok, pid} = FileSystem.start_link(dirs: directories)
    FileSystem.subscribe(pid)
    loop(modules)
  end

  defp loop(modules) do
    receive do
      {:file_event, _, _} ->
        modules |> Enum.each(fn(mod) -> IEx.Helpers.r(mod) end)
        loop(modules)
    end
  end
end
